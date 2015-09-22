/*
 * Copyright 2014-2015 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 0.1
import webbrowsercommon.private 0.1

PopupBase {
    id: downloadDialog
    objectName: "downloadDialog"
    anchors.fill: parent
    property var activeTransfer
    property var downloadId
    property var singleDownload
    property var mimeType
    property var filename
    property alias contentType: peerPicker.contentType

    Component {
        id: downloadOptionsComponent
        Dialog {
            id: downloadOptionsDialog
            Column {
                spacing: units.gu(2)

                Item {
                    width: parent.width
                    height: mimetypeIcon.height

                    Icon {
                        id: mimetypeIcon
                        name: MimeDatabase.iconForMimetype(downloadDialog.mimeType)
                        height: units.gu(4.5)
                        width: height
                    }

                    Label {
                        id: filenameLabel
                        anchors.top: mimetypeIcon.top
                        anchors.left: mimetypeIcon.right
                        anchors.leftMargin: units.gu(2)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        horizontalAlignment: Text.AlignHCenterdd
                        elide: Text.ElideMiddle
                        text: downloadDialog.filename
                    }

                    Label {
                        anchors.top: filenameLabel.bottom
                        anchors.left: filenameLabel.left
                        anchors.right: filenameLabel.right
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        font.capitalization: Font.Capitalize
                        text: MimeDatabase.nameForMimetype(downloadDialog.mimeType)
                    }
                }

                Label {
                    width: parent.width
                    text: i18n.tr("Choose an application to open this file or add it to the downloads folder.")
                    wrapMode: Text.Wrap
                }

                Button {
                    text: i18n.tr("Choose an application")
                    objectName: "chooseAppButton"
                    color: UbuntuColors.green
                    width: units.gu(22)
                    height: units.gu(4)
                    visible: peerModel.peers.length > 0
                    onClicked: {
                        PopupUtils.close(downloadOptionsDialog)
                        pickerRect.visible = true
                    }
                }

                Button {
                    text: i18n.tr("Download")
                    objectName: "downloadFileButton"
                    width: units.gu(22)
                    height: units.gu(4)
                    color: peerModel.peers.length == 0 ? UbuntuColors.green : UbuntuColors.warmGrey
                    onClicked: {
                        downloadDialog.singleDownload.moveToDownloads = true
                        downloadDialog.singleDownload.start()
                        PopupUtils.close(downloadDialog)
                    }
                }

                Button {
                    text: i18n.tr("Cancel")
                    objectName: "cancelDownloadButton"
                    width: units.gu(22)
                    height: units.gu(4)
                    onClicked: PopupUtils.close(downloadDialog)
                }

            }
        }

    }

    ContentPeerModel {
        id: peerModel
        handler: ContentHandler.Destination
        contentType: downloadDialog.contentType
    }

    Rectangle {
        id: pickerRect
        anchors.fill: parent
        visible: false
        ContentPeerPicker {
            id: peerPicker
            handler: ContentHandler.Destination
            visible: parent.visible

            onPeerSelected: {
                activeTransfer = peer.request()
                activeTransfer.downloadId = downloadDialog.downloadId
                activeTransfer.state = ContentTransfer.Downloading
                PopupUtils.close(downloadDialog)
            }

            onCancelPressed: {
                PopupUtils.close(downloadDialog)
            }
        }
    }

    Component.onCompleted: {
        if (typeof(webapp) == 'undefined') {
            PopupUtils.open(downloadOptionsComponent, downloadDialog)
        } else {
            pickerRect.visible = true 
        }
    }
}
