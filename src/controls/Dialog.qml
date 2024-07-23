import QtQuick 2.1
import QtQuick.Window 2.2
import QtWebEngine 1.9

Window {
    id: window
    property alias currentWebView: webView
    flags: Qt.Dialog | Qt.WindowStaysOnTopHint
    width: 800
    height: 600
    visible: true
    onClosing: destroy()
    WebEngineView {
        id: webView
        anchors.fill: parent

        onGeometryChangeRequested: function(geometry) {
            window.x = geometry.x
            window.y = geometry.y
            window.width = geometry.width
            window.height = geometry.height
        }
    }
}
