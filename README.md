# atom-xsltransform package

### Overview
Transform XML Documents using XSL Stylesheets.

By default, this package uses JavaScript native XSLTProcessor, without any OS dependent tools.

If you would prefer to use a custom XSLT transform tool, you can specify the command in Settings.

### Instructions

To transform stylesheet:

* Open the XML file in Atom.
* CTRL-SHIFT-P "atom-xsltransform:transform-xml"
* Enter the path of the XSL stylesheet (default directory is same path as XML file)
* Press enter
* New pane is opened to the right with the transformed content.

![Select XSL](https://raw.githubusercontent.com/russlescai/atom-xsltransform/master/atom-xsltransform-screen-1.PNG)

![Transformed Document](https://raw.githubusercontent.com/russlescai/atom-xsltransform/master/atom-xsltransform-screen-2.PNG)

### Examples

For example, to use [saxon](http://saxonica.com):

```
java net.sf.saxon.Transform -s:%XML -xsl:%XSL
```

Or for Saxon for Windows:

```
"C:\Program Files\Saxonica\SaxonHE9.6N\bin\Transform.exe" -s:%XML -xsl:%XSL
```

Another example, to use [xsltproc](http://xmlsoft.org):

```
xsltproc %XSL %XML
```
