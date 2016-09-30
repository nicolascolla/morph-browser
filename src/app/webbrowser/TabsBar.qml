/*
 * Copyright 2015-2016 Canonical Ltd.
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

import webbrowserapp.private 0.1

import "."
import ".."

Item {
    id: root

    property alias model: repeater.model

    property real minTabWidth: 0 //units.gu(6)
    property real maxTabWidth: units.gu(20)
    property real tabWidth: model ? Math.max(Math.min(tabsContainer.maxWidth / model.count, maxTabWidth), minTabWidth) : 0

    property bool incognito: false

    property color fgColor: Theme.palette.normal.baseText

    property bool touchEnabled: true

    signal switchToTab(int index)
    signal requestNewTab(int index, bool makeCurrent)
    signal tabClosed(int index)

    MouseArea {
        anchors.fill: parent
        onWheel: {
            var angle = (wheel.angleDelta.x != 0) ? wheel.angleDelta.x : wheel.angleDelta.y
            if ((angle < 0) && (root.model.currentIndex < (root.model.count - 1))) {
                switchToTab(root.model.currentIndex + 1)
            } else if ((angle > 0) && (root.model.currentIndex > 0)) {
                switchToTab(root.model.currentIndex - 1)
            }
        }
    }

    MouseArea {
        id: newTabButton
        objectName: "newTabButton"

        anchors {
            left: tabsContainer.right
            leftMargin: units.gu(1)
            top: parent.top
            bottom: parent.bottom
        }
        width: height

        visible: !repeater.reordering

        Icon {
            width: units.gu(2)
            height: units.gu(2)
            anchors.centerIn: parent
            name: "add"
            color: incognito ? "white" : root.fgColor
        }

        onClicked: root.requestNewTab(root.model.count, true)
    }

    Component {
        id: contextualOptionsComponent
        ActionSelectionPopover {
            id: menu
            objectName: "tabContextualActions"
            property int targetIndex
            readonly property var tab: root.model.get(targetIndex)

            actions: ActionList {
                Action {
                    objectName: "tab_action_new_tab"
                    text: i18n.tr("New Tab")
                    onTriggered: root.requestNewTab(menu.targetIndex + 1, false)
                }
                Action {
                    objectName: "tab_action_reload"
                    text: i18n.tr("Reload")
                    enabled: menu.tab.url.toString().length > 0
                    onTriggered: menu.tab.reload()
                }
                Action {
                    objectName: "tab_action_close_tab"
                    text: i18n.tr("Close Tab")
                    onTriggered: root.tabClosed(menu.targetIndex)
                }
            }
        }
    }

    Item {
        id: tabsContainer
        objectName: "tabsContainer"

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: tabWidth * root.model.count
        readonly property real maxWidth: root.width - newTabButton.width - units.gu(2)

        Repeater {
            id: repeater

            property bool reordering: false

            delegate: MouseArea {
                id: tabDelegate
                objectName: "tabDelegate"

                readonly property int tabIndex: index
                readonly property BrowserTab tab: tabsModel.get(index)
                readonly property BrowserWindow tabWindow: window

                property real rightMargin: units.dp(1)
                width: tabWidth + rightMargin
                height: tabsContainer.height
                y: tabsContainer.y  // don't use anchor otherwise drag doesn't work

                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                readonly property bool dragging: drag.active
                drag {
                    target: (pressedButtons === Qt.LeftButton) ? tabDelegate : null
                    axis: Drag.XAndYAxis
                    minimumX: 0
                    maximumX: root.width - tabDelegate.width
                    filterChildren: true
                }
                
                DragHelper {
                    id: dragHelper
                    source: tabDelegate                
                }

                TabItem {
                    anchors.fill: parent

                    active: tabIndex === root.model.currentIndex
                    hoverable: true
                    incognito: root.incognito
                    title: model.title ? model.title : (model.url.toString() ? model.url : i18n.tr("New tab"))
                    icon: model.icon
                    fgColor: root.fgColor

                    touchEnabled: root.touchEnabled

                    rightMargin: tabDelegate.rightMargin

                    onClosed: root.tabClosed(index)
                    onSelected: root.switchToTab(index)
                    onContextMenu: PopupUtils.open(contextualOptionsComponent, tabDelegate, {"targetIndex": index})
                }

                Binding {
                    target: repeater
                    property: "reordering"
                    value: dragging
                }

                Binding on x {
                    when: !dragging
                    value: index * width
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 250
                    }
                }
                
                NumberAnimation {
                    id: resetVerticalAnimation
                    target: tabDelegate
                    duration: 250
                    property: "y"
                    to: 0
                }
                
                onPositionChanged: {
                    if (Math.abs(y) > height) {
                        // Reset visual position of tab delegate
                        resetVerticalAnimation.start();
                    
                        if (mouse.buttons === Qt.LeftButton) {
                            // Generate tab preview for drag handle
                            dragHelper.previewUrl = PreviewManager.previewPathFromUrl(tab.url); 
                        
                            var dropAction = dragHelper.execDrag(tab.url);
                            
                            if (dropAction === Qt.MoveAction) {
                                // Moved into another window
                                console.debug("Moved to another window, closing tab");
                                
                                // drag.active does not become false when
                                // closing the tab so set reordering back
                                repeater.reordering = false;

                                // Just remove from model and do not destory
                                // as webview is used in other window                                
                                tabsModel.remove(index);
                            } else if (dropAction === Qt.CopyAction) {
                                // Moved into the same window
                                
                                // So no action
                                console.debug("No action, dropped in same window");
                            } else if (dropAction === Qt.IgnoreAction) {
                                // Moved outside of any window
                                console.debug("Moved outside, generating new window");
                                
                                // drag.active does not become false when
                                // closing the tab so set reordering back
                                repeater.reordering = false;

                                // callback function only removes from model
                                // and not destroy as webview is in new window
                                browser.newWindowFromTab(tab, function() { tabsModel.remove(index); })
                            } else {
                                // Unknown state
                                console.debug("Unknown drop action:", dropAction);
                            }
                        }
                    }
                }
                onReleased: resetVerticalAnimation.start();
                onXChanged: {
                    if (!dragging) return
                    if (x < (index * width - width / 2)) {
                        root.model.move(index, index - 1)
                    } else if ((x > (index * width + width / 2)) && (index < (root.model.count - 1))) {
                        root.model.move(index + 1, index)
                    }
                }

                z: (root.model.currentIndex == index) ? 3 : 1 - index / root.model.count
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            width: root.width
            height: units.dp(1)
            color: "#cacaca"
            z: 2
        }
    }
}
