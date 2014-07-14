/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

Column {
    id: tab

    property alias title: label.text
    property var webview

    signal selected()
    signal closeRequested()

    Item {
        id: header

        width: parent.width
        height: units.gu(4)

        Row {
            anchors.fill: parent

            AbstractButton {
                id: closeButton

                height: parent.height
                width: units.gu(5)

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                }

                Icon {
                    height: units.gu(3)
                    width: height
                    anchors.centerIn: parent
                    name: "close"
                }

                onTriggered: tab.closeRequested()

                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width: units.dp(1)

                    color: "#d9d9d9"
                }
            }

            Item {
                width: parent.width - closeButton.width
                height: parent.height

                Image {
                    id: tabBackgroundLeft
                    height: parent.height
                    anchors {
                        left: parent.left
                        right: tabBackgroundCenter.left
                    }
                    source: "assets/tab-header-left.png"
                    fillMode: Image.TileHorizontally
                }

                Image {
                    id: tabBackgroundCenter
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "assets/tab-header-center.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: tabBackgroundRight
                    height: parent.height
                    anchors {
                        left: tabBackgroundCenter.right
                        right: parent.right
                    }
                    source: "assets/tab-header-right.png"
                    fillMode: Image.TileHorizontally
                }

                Label {
                    id: label
                    anchors {
                        fill: tabBackgroundLeft
                        leftMargin: units.gu(1)
                    }
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }

    Item {
        // inactive webview / image

        width: parent.width
        height: parent.height - header.height

        // XXX: temporary placeholder
        Rectangle {
            color: "red"
            opacity: 0.4
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: tab.selected()
        }
    }
}
