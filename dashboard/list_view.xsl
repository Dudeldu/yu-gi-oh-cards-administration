<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml"
                doctype-public="-//W3C//DTD XHTML 1.1//EN"
                doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
    <xsl:template match="/root">
        <html>
            <head>
                <title>Yu-Gi-Oh! Cards</title>
                <style>
                    form{
                    text-align: center;
                    border: solid black 2px;
                    width: 80%;
                    margin:auto;
                    margin-top: 20px;
                    margin-bottom: 20px;
                    }
                </style>
                <link rel="stylesheet" type="text/css" href="dashboard/dashboard.css"/>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/feather-icons/4.9.0/feather.min.js"/>
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"/>
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"/>
                <script src="dashboard/dashboard.js"/>
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
                            </div>
                        </nav>

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
                                                <tr>
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
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>