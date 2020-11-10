function loaded() {
	var ENV = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
	var obj = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
	if (ENV.exists("TEMP")) {
		obj.initWithPath(ENV.get("TEMP")+"\\xulrunner\\loaded.tmp");
		obj.create(Components.interfaces.nsIFile.NORMAL_FILE_TYPE, 0666);
	}
}

function shutdown() {
	var ENV = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
	var obj = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
	if (ENV.exists("TEMP")) {
		obj.initWithPath(ENV.get("TEMP")+"\\purge-slideCD.exe");
		obj.launch();
	}
}

function FillInHTMLTooltip(tipElement) {

	var retVal = false;
	if (tipElement.namespaceURI == "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul")
	return retVal;

	const XLinkNS = "http://www.w3.org/1999/xlink";

	var titleText = null;
	var XLinkTitleText = null;

	while (!titleText && !XLinkTitleText && tipElement) {
		if (tipElement.nodeType == Node.ELEMENT_NODE) {
			titleText = tipElement.getAttribute("title");
			XLinkTitleText = tipElement.getAttributeNS(XLinkNS, "title");
		}
		tipElement = tipElement.parentNode;
	}

	var texts = [titleText, XLinkTitleText];
	var tipNode = document.getElementById("aHTMLTooltip");

	for (var i = 0; i < texts.length; ++i) {
		var t = texts[i];
		if (t && t.search(/\S/) >= 0) {
			tipNode.setAttribute("label", t);
			retVal = true;
		}
	}

	return retVal;
}