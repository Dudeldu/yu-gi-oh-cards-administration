#YU-GI-OH Cards administration tool

## Installation
Install required packages with pip:  
```pip install -r requirements.txt```
Download and install [sqlite](https://www.sqlite.org/index.html)  

## Usage
Start the python script and add the database as one required parameter and 
optional directly start the webinterface with the last parameter:  
```python main.py <path to db> <start webinterface>```  
Example:  
```python main.py cards.db True ```  
Look into ```!help``` for more information about possible commands  

## Lifecycle

 1. Add your cards  
    - with the ```!add``` command an enter every Card-ID (on the right over the description). Finish with ```!end```
    - in the main menu adding the card with ```!<link to the card at cardmarket>```  
 2. The script pulls information from [cardmarket](https://www.cardmarket.com/de/YuGiOh) and the [ygoprodeck-cardinfo API](https://db.ygoprodeck.com/api-guide/) and stores them into the database
 3. Export your cards' data as csv/xml file if needed with the commands ```dump csv <path to file>```/```dump xml <path to file>```
 4. Start the webinterface by entering ```!webinterface``` and do different searches with SQL Command or simply by search for a name