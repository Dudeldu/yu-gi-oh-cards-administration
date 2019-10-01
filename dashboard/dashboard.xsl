<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xhtml"
                doctype-public="-//W3C//DTD XHTML 1.1//EN"
                doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
    <xsl:template match="/root">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Yu-Gi-Oh! Cards</title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                <link rel="stylesheet" type="text/css" href="dashboard/dashboard.css"/>
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
                <script src="https://code.jquery.com/jquery-3.4.1.min.js">
                    // <![CDATA[ // ]]>
                </script>
                <script src="dashboard/dashboard.js">
                    //Use this workaround described here: https://stackoverflow.com/questions/336670/explicit-script-end-tag-always-converted-to-self-closing
                    //to make the server side xslt transformation working and prevent the script tag to not being closed
                    // <![CDATA[ // ]]>
                </script>
            </head>
            <body>
                <nav class="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
                    <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="./">Yu-Gi-Oh! Cards</a>
                    <form action="/query" autocomplete="off">
                        <input class="form-control form-control-dark w-100" type="text" name="query" placeholder="SQL-Query/Search for name"
                               aria-label="SQL-Query">
                        </input>
                    </form>
                </nav>
                <div class="container-fluid">
                    <div class="row">
                        <nav class="col-md-2 d-none d-md-block bg-light sidebar" style="top: 45px;position: fixed">
                            <div class="sidebar-sticky">
                                <ul class="nav flex-column">
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type='Spell Card' ORDER BY name ASC">
                                            <span data-feather="file"/>
                                            Spell Cards
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type='Trap Card' ORDER BY name ASC">
                                            <span data-feather="shopping-cart"/>
                                            Trap Cards
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type='Normal Monster' ORDER BY name ASC">
                                            <span data-feather="users"/>
                                            Normal Monster
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type='Effect Monster' ORDER BY name ASC">
                                            <span data-feather="bar-chart-2"/>
                                            Effect Monster
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type='Synchro Monster'
                                        OR type='Fusion Monster' ORDER BY type, name ASC">
                                            <span data-feather="layers"/>
                                            Synchro and Fusion Monster
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" href="?query=SELECT * FROM Cards WHERE type!='Synchro Monster' AND type!='Fusion Monster' AND type!='Effect Monster' AND type!='Normal Monster' AND type!='Trap Card' AND type!='Spell Card' ORDER BY type, name ASC">
                                            <span data-feather="layers"/>
                                            Other cards
                                        </a>
                                    </li>
                                </ul>
                                <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                                    <span>Options</span>
                                </h6>
                                <ul class="nav flex-column mb-2">
                                    <li class="nav-item">
                                        <a class="nav-link" href="#" onclick="$('#exampleModal').modal('toggle')">
                                            <span data-feather="layers"/>
                                            Add new cards
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </nav>

                        <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                          <div class="modal-dialog" role="document">
                            <div class="modal-content">
                              <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLabel">Add Cards</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                  <span aria-hidden="true">&#xD7;</span>
                                </button>
                              </div>
                              <div class="modal-body addCardList">
                                <div class="input-group mb-3 addCardListItem">
                                    <div class="input-group-prepend">
                                    <span class="input-group-text">CardID</span>
                                    </div>
                                    <input onchange="onCardEntered(this)" type="text" class="form-control"/>
                                    <div class="none">
                                        <div class="spinner-border pendingIcon" role="status">
                                          <span class="sr-only">Loading...</span>
                                        </div>
                                        <div class="okIcon">
                                            &#10003;
                                        </div>
                                        <div class="cancelIcon">
                                            &#xD7;
                                        </div>
                                    </div>
                                </div>
                              </div>
                              <div class="modal-footer">
                                <button id="modalCloseBtn" type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                              </div>
                            </div>
                          </div>
                        </div>

                        <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
                            <h2 style="margin-top: 45px;"><span class="overflow-span" id="query" onclick="insertQueryToSearch()"><xsl:value-of select="@query"/></span></h2>
                            <div class="table-responsive">
                                <table class="table table-striped table-sm">
                                    <xsl:if test="card">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Type</th>
                                                <th>Collection</th>
                                                <th>Price</th>
                                                <th>Description</th>
                                                <th>Image</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="card">
                                                <tr class=".tableCardRow">
                                                    <td>
                                                        <xsl:value-of select="@name"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="@type"/>
                                                    </td>
                                                    <td>
                                                        <a style="color: black; text-decoration: underline">
                                                            <xsl:attribute name="href">
                                                                ?query=SELECT * FROM Cards WHERE collection='<xsl:value-of select="@collection"/>'ORDER BY type, name ASC
                                                            </xsl:attribute>
                                                            <xsl:value-of select="@collection"/>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="@url"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="@price"/>€
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="@desc"/>
                                                    </td>
                                                    <td>
                                                        <img width="140">
                                                            <xsl:attribute name="src">
                                                                <xsl:value-of select="@img"/>
                                                            </xsl:attribute>
                                                            <xsl:attribute name="alt">
                                                                <xsl:value-of select="@img"/>
                                                            </xsl:attribute>
                                                        </img>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </xsl:if>
                                    <xsl:if test="element">
                                        <tbody>
                                            <xsl:for-each select="element">
                                                <tr>
                                                    <xsl:for-each select="@*">
                                                        <td>
                                                            <xsl:value-of select="."/>
                                                        </td>
                                                    </xsl:for-each>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </xsl:if>
                                </table>
                            </div>
                        </main>
                    </div>
                </div>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js">
                    // <![CDATA[ // ]]>
                </script>
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js">
                    // <![CDATA[ // ]]>
                </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>