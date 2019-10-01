import requests
import sqlite3
import threading
import sys
import xml.etree.cElementTree as ET
from flask import Flask
import flask
import webbrowser
import logging
from tqdm import tqdm
import lxml.etree as ET

log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

app = Flask("Yu-Gi-Oh! - Webinterface")


def write_card(name, collection, id, url, price, en_name, json):
    """
    Adding the card to the database
    :param name: name of card (german name)
    :param collection: name of the collection, the card appeared in
    :param id: <collection abbreviation>-<language><nr in collection> (e.g.: SDRL-DE018)
    :param url: url of cardmarket for the card
    :param price: the current price of the card at cardmarket
    :param en_name: english name of the card
    :param json: json returned from ygoprodeck-cardinfo API for specific card
    """
    conn = sqlite3.connect(db)
    c = conn.cursor()
    c.execute("""INSERT INTO Cards VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)""", (name, en_name, collection, url,
                                                                          json["card_images"][0]["image_url"], id,
                                                                          json["type"], price, json["desc"]))
    conn.commit()
    conn.close()


def dump_xml(file):
    """
    Dump database content into xml file
    :param file: path to the xml file
    """
    conn = sqlite3.connect(db)
    c = conn.cursor()
    rows = c.execute("""SELECT * FROM Cards;""").fetchall()
    cards_tag = ET.Element("cards")
    for row in rows:
        ET.SubElement(cards_tag, "card", {"name": row[0], "collection": row[2], "url": row[3], "img": row[4],
                                          "type": row[6], "price": str(row[7]), "desc": row[8]})
    ET.ElementTree(cards_tag).write(file)
    conn.close()
    print("Database successfully exported to '" + str(file) + "'")


def dump_csv(file):
    """
    Dump database content into csv file
    :param file: path to the csv file
    """
    conn = sqlite3.connect(db)
    c = conn.cursor()
    rows = c.execute("""SELECT * FROM Cards;""").fetchall()
    output_file = open(file, "w", encoding="utf-8")
    output_file.write("name, collection, url, img, type, price, description\n")
    for row in rows:
        line = [row[0], row[2], row[3], row[4], row[6], str(row[7]), row[8]]
        output_file.write(",".join(line) + "\n")
    conn.close()
    print("Database successfully exported to '" + str(file) + "'")


def update_price(query=None):
    """
    Updating the price of the cards specified by the sql-query from cardmarkets.com
    !Attention!: Can take a while due to the long response time of cardmarket
    :param query: SQL-Query for the cards or NONE to update all cards
    """
    conn = sqlite3.connect(db)
    c = conn.cursor()
    if query is None:
        rows = c.execute("""SELECT * FROM Cards;""").fetchall()
    else:
        rows = c.execute(query).fetchall()
    c = conn.cursor()
    for row in tqdm(rows):
        response = requests.get(row[3])
        html = response.text
        price = html.split("Preis-Trend</dt><dd class=\"col-6 col-xl-7\"><span>")[-1].split("<")[0]
        price = float(price.split()[0].replace(",", "."))  # get the price trend
        c.execute("""UPDATE Cards SET price=? WHERE url=?""", (price, row[3]))
    conn.commit()
    conn.close()


def remove_cards(params):
    name = params[0].lstrip().rsplit()[0]
    collection = params[1].lstrip().rsplit()[0]
    conn = sqlite3.connect(db)
    c = conn.cursor()
    rowid = c.execute("""SELECT rowid FROM Cards WHERE name=? AND collection=? limit 1""",
                      (name, collection)).fetchone()
    if rowid is None:
        print("No card specified with name: " + name + " and collection: " + collection)
    else:
        c.execute("""DELETE FROM Cards WHERE rowid = ?;""", rowid)
        print("Successful removed card: " + str(name))
    conn.commit()
    conn.close()


def eval_card_id(card_id=None, url=None, sound=False):
    try:
        if url is None:
            response = requests.get(
                "https://www.cardmarket.com/de/YuGiOh/Products/Search?searchString={}".format(card_id))
            url = response.url
        else:
            response = requests.get(url)
        collection, name = response.url.split("/")[-2:]
        html = response.text
        price = html.split("Preis-Trend</dt><dd class=\"col-6 col-xl-7\"><span>")[-1].split("<")[0]
        price = float(price.split()[0].replace(",", "."))  # get the price trend
        sub_header = html.split("h4 text-muted font-weight-normal font-italic\">")[-1].split("<")[0]
        # split off the first part(collection info) and the last part (package info)
        en_name = " - ".join(sub_header.split(" - ")[1:-1])
        en_name = en_name.split("(")[0]  # remove '(rare 1st edition ...)' text
        if en_name == "":  # if name is same in all languages
            en_name = name
        json = requests.get("https://db.ygoprodeck.com/api/v5/cardinfo.php?name={}".format(en_name)).json()[0]
        write_card(name, collection, card_id, url, price, en_name, json)
        return 0
    except:
        print("\nNOT FOUND " + str(card_id) + "\n", file=sys.stderr)
        if sound:
            print("\a")
        return -1


@app.route("/")
def base():
    return flask.redirect("/query")


@app.route("/shutdown")
def shutdown():
    shutdown_func = flask.request.environ.get('werkzeug.server.shutdown')
    if shutdown_func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    shutdown_func()
    return "Shutting webservice down"


@app.route("/dashboard/<file>")
def deliver_static_files(file):
    return flask.send_from_directory("dashboard", file)


@app.route("/update")
def handler_update():
    update_price(flask.request.args.get("query"))
    return flask.jsonify({"status": "successful"}), 200


@app.route("/card/add", methods=["POST"])
def add_card():
    card_id = flask.request.form.get("id")
    if card_id is None:
        return flask.jsonify({"error": "no card id provided"}), 400
    if eval_card_id(card_id, url=None, sound=False) >= 0:
        return flask.jsonify({"status": "added"}), 200
    return flask.jsonify({"status": "error"}), 503


@app.route("/remove", methods=["DELETE"])
def handler_remove():
    name = flask.request.form.get("name")
    collection = flask.request.form.get("collection")
    if name is None or collection is None:
        return flask.jsonify({"status": "Bad request"}), 400
    else:
        remove_cards([name, collection])
        return flask.jsonify({"status": "successful"}), 200


@app.route('/<query>')
def query(query):
    if "favicon" in query:
        return flask.redirect("https://seeklogo.com/images/Y/Yu-Gu-Oh_-logo-FA1A029B70-seeklogo.com.png")
    if "query" in query.lower():
        conn = sqlite3.connect(db)
        c = conn.cursor()
        query_string = flask.request.args.get('query')
        if query_string is None or query_string == " " or query_string == "":
            query_string = "SELECT * FROM Cards ORDER BY name ASC;"
        if "select" not in query_string.lower():
            query_string = "SELECT * FROM Cards WHERE name LIKE '%" + query_string + "%'"
        rows = c.execute(query_string).fetchall()
        try:
            root_tag = ET.Element("root", {"query": query_string})
            for row in rows:
                ET.SubElement(root_tag, "card", {"name": row[0], "collection": row[2], "url": row[3], "img": row[4],
                                                 "type": row[6], "price": str(row[7]), "desc": row[8]})
        except:
            root_tag = ET.Element("root", {"query": query_string})
            for row in rows:
                attrib = {}
                for i, elem in enumerate(row):
                    attrib["elem" + str(i)] = str(elem)
                ET.SubElement(root_tag, "element", attrib)
        '''
        Use server side xslt transformation instead of client side,
         - because this is the only way bootstrap.js works properly
         - it generates browser independent html code
        '''
        conn.close()
        xslt = ET.parse("dashboard/dashboard.xsl")
        transformer = ET.XSLT(xslt, regexp=False)
        return ET.tostring(transformer(root_tag))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("You have to specify a directory for the db, start with 'python main.py <path to db> <start webinterface>"
              "'\nParameter:\n"
              "    - path to db (required) path to the database containing the cards\n"
              "    - start webinterface (optional) directly start the webinterface [default=True]\n")
    else:
        db = sys.argv[1]
        # Create table in the database for the first time
        cur = sqlite3.connect(db).cursor()
        try:
            cur.execute("""SELECT * FROM Cards;""")
            cur.close()
        except sqlite3.OperationalError:
            cur.execute("""CREATE TABLE CARDS(
                            name varchar(255),
                            en_name varchar(255),
                            collection varchar(255),
                            url varchar(255),
                            img varchar(255),
                            id varchar(16),
                            type varchar(64),
                            price REAL,
                            description TEXT
                            );""")
            cur.close()
        if len(sys.argv) == 2 or (len(sys.argv) == 3 and sys.argv[2] == "True"):
            flask_thread = threading.Thread(target=app.run)
            flask_thread.start()
            webbrowser.open("http://127.0.0.1:5000/query")
        elif sys.argv[2] == "False":
            flask_thread = None
        else:
            raise Exception("Wrong value provided for start webinterface: " + str(sys.argv[2:]))

        while True:
            cmd = input(">> ")
            if cmd.startswith("!quit") or cmd.startswith("!exit"):
                if flask_thread is not None:
                    requests.get("http://127.0.0.1:5000/shutdown")
                    flask_thread.join()
                break
            elif cmd.startswith("!add"):
                while True:
                    card_id = input("CARD ID: ")
                    if card_id.startswith("!end"):
                        break
                    threading.Thread(target=eval_card_id, args=(card_id, None, True)).start()
            elif cmd.startswith("!dump csv"):
                dump_csv(cmd.replace("!dump csv", ""))
            elif cmd.startswith("!dump xml"):
                dump_xml(cmd.replace("!dump xml", ""))
            # if command starts with http -> it is a cardmarket link
            elif cmd.startswith("!http"):
                threading.Thread(target=eval_card_id, args=(None, cmd.replace("!", ""))).start()
            elif cmd.startswith("!webinterface"):
                if flask_thread is None:
                    flask_thread = threading.Thread(target=app.run)
                    flask_thread.start()
                webbrowser.open("http://127.0.0.1:5000/query")
            elif cmd.startswith("!update"):
                update_price(cmd.replace("!update", ""))
            elif cmd.startswith("!remove"):
                remove_cards(cmd.replace("!remove", "").split(","))
            elif cmd.startswith("!help"):
                print("Possible commands:\n"
                      " - !quit / !exit         close the program\n"
                      " - !add                  start the card adding loop\n"
                      "     - !end                  exits the card adding loop, that was accessed via !add\n"
                      " - !<link to card>       adds a card specified with the cardmarket-link to the card\n"
                      " - !dump csv <dir>       dumps the cards saved in the database to a csv-file\n"
                      " - !dump xml <dir>       dumps the cards saved in the database to a xml-file\n"
                      " - !webinterface         starts the backend for the webinterface and opens browser\n"
                      " - !update <sql-query>   updates the price from cardmarket\n"
                      " - !remove <card name>,<collection name>\n"
                      "                         removes the specified card ONCE", flush=True)
            else:
                print("\a'" + cmd + "' isn't a known command\nEnter !help to get a list of possible commands",
                      flush=True)
