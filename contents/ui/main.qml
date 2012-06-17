import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.qtextracomponents 0.1 as QtExtra

Item {
	id: dashboard
	width: 500
	height: 300
	property int screenWidth: 0
	property int screenHeight: 0
	property int dashHeight: 0
    
	property int launcherWidth: 130
	property int dockHeight: 40
    
	property int hideContentX: screenWidth - (screenWidth * 2) - 10
	property int showContentX: 0
	property int hideLauncherX: -200
	property int showLauncherX: 0
	
	property int previousIndex : 0
	
	property string searchQuery : ''
	property int mininumStringLength : 3
	
	property int runningActivities : 0
	property string currentActivity : ''
	property variant stateSource
	
	// category button component
	Component {
		id: dashboardCategoryButton
		
		Image {
			id: dashboardCategoryImage
			fillMode: Image.PreserveAspectFit
			source: "../images/" + icon
			width: 64
			height: 64
			opacity: 0.3
			anchors.horizontalCenter: parent.horizontalCenter
			
			states: [
				State {
					name: "active"
					when: dashboardCategories.currentIndex == index
					
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 1
					}
					
					PropertyChanges {
						target: views.children[index]
						opacity: 1
					}
				},
				
				State {
					name: "hover"
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 0.5
					}
				},
				
				State {
					name: "hide"
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 0
					}
				}
			]
			
			transitions: Transition {
				PropertyAnimation { property: "opacity"; duration: 100 }
			}
			
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				
				onEntered: {
					if(parent.state != "active") parent.state = "hover"
				}
				
				onExited: {
					if(parent.state != "active") parent.state = ""
				}
				
				onClicked: {
				
					// activate button
					dashboardCategories.currentIndex = index;
					
					if(workspace.activeClient && workspace.activeClient.normalWindow) {
						// show desktop - minimize everything
						workspace.slotToggleShowDesktop();
					}
					
				}
			}
			
			Component.onCompleted: {
				if(icon == "searchIcon.png") {
					dashboardCategoryImage.state = "hide";
				}
			}
			
		}
		
	}
	
	// categories model
	ListModel {
		id: dashboardCategoriesModel
		
		ListElement {
			icon: "windowsIcon.png"
		}
		
		ListElement {
			icon: "applicationsIcon.png"
		}
		
		ListElement {
			icon: "activitiesIcon.png"
		}
		
		ListElement {
			icon: "searchIcon.png"
		}

	}

	// dashboard categories
	Item {
		id: dashboardCategoriesContainer
		width: launcherWidth
		height: (dashboardContent.x == showContentX) ? dashHeight : screenHeight
		
		ListView {
			id: dashboardCategories
			width: parent.width
			height: 320
			spacing: 20
			anchors {
				top: parent.top
				topMargin: 200
				bottom: parent.bottom
			}
			currentIndex: -1
			
			model: dashboardCategoriesModel
			delegate: dashboardCategoryButton
			
			highlight: Rectangle {
				width: 3
				opacity: 0.8
				color: "white"
			}
			
			// show content dialog when anything selected
			states: [
				State {
					name: "showContentDialog"
					when: dashboardCategories.currentIndex != -1
					
					PropertyChanges {
						target: dashboardContent
						x: showContentX
					}
				}
				
			]
		}
	
	}
	
	// dashboard views
	Item {
		id: viewsContainer
		width: screenWidth
		height: dashHeight
		
		Plasma.TextField {
			id: searchField
			placeholderText: 'Search..'
			width: 190
			anchors {
				top: parent.top
				topMargin: 20
				right: parent.right
				rightMargin: 20
			}
			
			onTextChanged: {
				
				if(text.length >= mininumStringLength) {
				
					// set search query
					searchQuery = text.toLowerCase();
					
					// activate search view
					dashboardCategories.currentIndex = 3;
					
					// search - activities
					searchView.search();
					
				} else {
					
					// activate windows
					dashboardCategories.currentIndex = previousIndex;
					
					// hide search button
					dashboardCategories.contentItem.children[4].state = "hide";
					
				};
				
				
			}

		}
		
		MouseArea {
			anchors.fill: searchField
			onClicked: {
				searchField.forceActiveFocus();
				console.log('click-textarea');
			}
		}
		
		Item {
			id: views
			
			anchors {
				top: searchField.bottom
				topMargin: 50
				left: parent.left
				leftMargin: 200
				right: parent.right
				rightMargin: 10
				bottom: parent.bottom
			}
			
			WindowSwitcher {
				id: windowsView
				opacity: 0
				visible: (windowsView.opacity) ? true : false
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: windowsView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
				
			}
			
			Applications {
				id: applicationsView
				opacity: 0
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: applicationsView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
			
			Activities {
				id: activitiesView
				opacity: 0
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: activitiesView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
			
			Search {
				id: searchView
				opacity: 0

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
		}
	}
	
	PlasmaCore.Dialog {
        id: dashboardContent
        x: hideContentX
        windowFlags: Qt.X11BypassWindowManagerHint
        
        mainItem: viewsContainer
        
		Behavior on x {
			id: contentTransition
			PropertyAnimation {
				properties: "x"
				easing.type: Easing.InOutQuad
			}
			enabled: false
		}
	}
	
	// dashboard launcher/categories
	PlasmaCore.Dialog {
        id: launcher
        x: hideLauncherX
        windowFlags: Qt.X11BypassWindowManagerHint
        
        mainItem: dashboardCategoriesContainer
		
		Behavior on x {
			id: launcherTransition
			PropertyAnimation {
				properties: "x"
				easing.type: Easing.InOutQuad
			}
			enabled: false
		}
	}
	
	// dashboard button
	PlasmaCore.Dialog {
        id: dashboardButton
        x: 0
        y: 0
        windowFlags: Qt.X11BypassWindowManagerHint
        
        mainItem: dashboardButttonContainer
	}
	
	Item {
		id: dashboardButttonContainer
		width: 25
		height: 18
		
		Plasma.ToolButton {
			anchors.fill: parent
			
			onClicked: toggleBoth()
			
			Image {
				id: dashboardIcon
				width: 15
				height: 15
				source: "../images/dashboardIcon.png"
				
				anchors {
					left: parent.left
					leftMargin: 5
				}
				
				opacity: (dashboardContent.x == showContentX) ? 1 : 0.5
				
				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
		}
	}
	
	
	Component.onCompleted: {

		var screen = workspace.clientArea(KWin.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
        screenWidth = screen.width;
        screenHeight = screen.height;
		
		dashHeight = screenHeight - dockHeight;
		
		dashboardContent.x = hideContentX;
		launcher.x = hideLauncherX;
		dashboardContent.y = launcher.y = 20;
		
		dashboardContent.visible = true;
		launcher.visible = true;
		
		contentTransition.enabled = launcherTransition.enabled = true;
		
		
		dashboardButton.visible = true;
		
		// register left screen edge
		registerScreenEdge(KWin.ElectricLeft, function() {
			toggleLauncher();
		});
		
		// register top-left screen edge
		registerScreenEdge(KWin.ElectricTopLeft, function() {
			toggleBoth();
		});
		
    }
    
	// activities source
	PlasmaCore.DataSource {
		id: activitiesSource
		dataEngine: "org.kde.activities"

		onSourceAdded: {
			connectSource(source);
			runningActivities++;
		}
		
		onSourceRemoved: {
			runningActivities--;
		}
		
		Component.onCompleted: {
			stateSource = sources[sources.length - 1];
			connectedSources = sources;
			
			runningActivities = activitiesSource.data[stateSource].Running.length;
			
			// connect signal after connecting sources
			activitiesSource.dataChanged.connect(function() {
				runningActivities = activitiesSource.data[stateSource].Running.length;
				
				currentActivity = activitiesSource.data[stateSource].Current;
				
				// get new windows for activity
				
				// when changed activity, get new windows
				windowThumbs.clear();
				
				// add new clients to model
				var clients = workspace.clientList();
				
				var i = 0;
				for (i = 0; i < clients.length; i++) {
					
					if(visibleClient(clients[i])) {
						
						// match activity
						if(clients[i].activities == "" || clients[i].activities == currentActivity) {
							
							windowThumbs.append({
								"windowId": clients[i].windowId,
								"gridId": windowThumbs.count,
								"client": clients[i]
							});
						
						};
						
					}
					
				}
				
				// recalculate thumb size
				windowsView.recalculateCellSize();
				
			})
			
		}
	}
	
	PlasmaCore.DataSource {
		id: executableSource
		dataEngine: "executable"
	}
	
	ListModel {
		id: windowThumbs
	}
	
	PlasmaCore.DataModel {
		id: activitiesModel
		dataSource: activitiesSource
    }
    
    // toggle dashboard categories
    function toggleLauncher() {
		if(launcher.x == showLauncherX) {
			launcher.x = hideLauncherX;
			
			if(dashboardCategories.currentIndex != -1) {
				// hide content
				dashboardCategories.currentIndex = -1;
				
				// show previous apps - unminimize everything
				workspace.slotToggleShowDesktop();
			}
			
		} else {
			launcher.x = showLauncherX;
		}
	}
	
	// toggle complete dashboard
	function toggleBoth() {
		if(launcher.x == showLauncherX) {
			if(dashboardCategories.currentIndex != -1) {
				toggleLauncher();
			} else {
				// show content
				dashboardCategories.currentIndex = 0;
				
				// check if there are any normalWindows active/everything is not minimized already
				if(workspace.activeClient && workspace.activeClient.normalWindow) {
					// show desktop - minimize everything
					workspace.slotToggleShowDesktop();
				}
			}
		} else {
			// show launcher
			toggleLauncher();
			
			// show content
			dashboardCategories.currentIndex = 0;
			
			// check if there are any normalWindows active/everything is not minimized already
			if(workspace.activeClient && workspace.activeClient.normalWindow) {
				// show desktop - minimize everything
				workspace.slotToggleShowDesktop();
			}
		}
	}
	
	// check if the client/window should be visible in the windowSwitcher
    function visibleClient(client) {
		if(client.dock || client.skipSwitcher || client.skipTaskbar || !client.normalWindow) {
			return false;
		} else {
			return true;
		}
	}
	
	// add and remove clients when added/removed
	Connections {
		target: workspace
		
		onClientAdded: {
			// hide dashboard when adding a new client (popup-plasmoids, windows, apps, etc.)
			if(launcher.x == showLauncherX) toggleLauncher();
		}
		
		onClientActivated: {
			// hide dashboard when activating a new "normalWindow" client
			if(client && client.normalWindow && launcher.x == showLauncherX) {
				launcher.x = hideLauncherX;
				dashboardCategories.currentIndex = -1;
			}
		}
	}
    
}