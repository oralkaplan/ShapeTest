import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Shapes 1.15

Window
{
    width: 640
    height: 880
    visible: true
    title: "Shape test"

    MouseArea {
        property QtObject currentShape: null

        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            let pos = convertToNormalized( mouseX, mouseY, width, height )
            currentShape = comp_shape.createObject( itm_img, {
                                                       start_nx: pos.nx,
                                                       start_ny: pos.ny,
                                                       end_nx: pos.nx,
                                                       end_ny: pos.ny })
        }
        onPositionChanged: {
            if( pressed && currentShape ) {
                let pos = convertToNormalized( mouseX, mouseY, width, height )
                currentShape.end_nx = pos.nx
                currentShape.end_ny = pos.ny
            }
        }
        onReleased: {
            if( currentShape ) {
                currentShape = null
            }
        }
        onWheel: {
            if( wheel.angleDelta.y > 0 )
                itm_img.scale += 0.2
            else
                itm_img.scale -= 0.2
        }
    }

    Item {
        id: itm_img

        anchors.fill: parent
    }

    Component {
        id: comp_shape

        Item {
            id: root

            required property real start_nx
            required property real start_ny
            property real end_nx
            property real end_ny
            readonly property real calcX: parent.width * start_nx
            readonly property real calcY: parent.height * start_ny
            readonly property real calcW: parent.width * ( end_nx - start_nx )
            readonly property real calcH: parent.height * ( end_ny - start_ny )

            x: calcX
            y: calcY
            width: calcW
            height: calcH

            Item {
                id: itm_shape

                anchors.fill: parent

                Shape {
                    id: shp_shape

                    readonly property real dx: width
                    readonly property real dy: height
                    readonly property real rx: dx * 0.5
                    readonly property real ry: dy * 0.5

                    anchors {
                        fill: parent
                        margins: parent.border.width
                    }
                    asynchronous: true
                    smooth: true
                    vendorExtensionsEnabled: true

                    ShapePath {
                        id: sp_boundingBox

                        strokeWidth: 1.0
                        strokeColor: "royalblue"
                        strokeStyle: ShapePath.DashLine

                        PathSvg {
                            path: "L %1 0 L %1 %2 L 0 %2 z"
                            .arg( shp_shape.dx )
                            .arg( shp_shape.dy )
                        }
                    }

                    ShapePath {
                        id: sp_arc

                        strokeWidth: 1.0
                        strokeColor: "crimson"
                        strokeStyle: ShapePath.SolidLine

                        PathSvg {
                            path: "M 0 %1 A %2 %3 0 0 1 %4 %5"
                            .arg( shp_shape.ry )
                            .arg( shp_shape.rx )
                            .arg( shp_shape.ry )
                            .arg( shp_shape.dx )
                            .arg( shp_shape.ry )
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                }
            }

            Rectangle {
                id: rect_topHandle

                anchors {
                    horizontalCenter: itm_shape.horizontalCenter
                    verticalCenter: itm_shape.top
                }
                color: "turquoise"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onMouseYChanged: {
                        if( pressed ) {
                            let ny = normalize( mouseY, root.parent.height )
                            root.start_ny += ny
                        }
                    }
                }
            }

            Rectangle {
                id: rect_rightHandle

                anchors {
                    horizontalCenter: itm_shape.right
                    verticalCenter: itm_shape.verticalCenter
                }
                color: "red"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onMouseXChanged: {
                        if( pressed ) {
                            let nx = normalize( mouseX, root.parent.width )
                            root.end_nx += nx
                        }
                    }
                }
            }

            Rectangle {
                id: rect_bottomHandle

                anchors {
                    horizontalCenter: itm_shape.horizontalCenter
                    verticalCenter: itm_shape.bottom
                }
                color: "blue"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onMouseYChanged: {
                        if( pressed ) {
                            let ny = normalize( mouseY, root.parent.height )
                            root.end_ny += ny
                        }
                    }
                }
            }

            Rectangle {
                id: rect_leftHandle

                anchors {
                    horizontalCenter: itm_shape.left
                    verticalCenter: itm_shape.verticalCenter
                }
                color: "lime"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onMouseXChanged: {
                        if( pressed ) {
                            let nx = normalize( mouseX, root.parent.width )
                            root.start_nx += nx
                        }
                    }
                }
            }

            Rectangle {
                id: rect_originHandle

                readonly property real centerX: width * 0.5
                readonly property real centerY: height * 0.5

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                color: "slateblue"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onPositionChanged: {
                        if( pressed ) {
                            let nx = normalize( mouseX, root.parent.width )
                            let ny = normalize( mouseY, root.parent.height )
                            root.start_nx += nx
                            root.start_ny += ny
                            root.end_nx += nx
                            root.end_ny += ny
                        }
                    }
                }
            }

            Rectangle {
                id: rect_rotationHandle

                readonly property real centerX: width * 0.5
                readonly property real centerY: height * 0.5

                anchors {
                    horizontalCenter: parent.right
                    verticalCenter: parent.top
                }
                color: "coral"
                width: 8
                height: 8
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onPositionChanged: {
                        if( pressed ) {
                            let diffX = parent.x - rect_originHandle.x
                            let diffY = -1.0 * ( parent.y - rect_originHandle.y )
                            let initialAngle = Math.atan2( diffY, diffX )
                            let mapped = mapToItem( root, mouseX, mouseY )
                            calculateAngle( mapped, initialAngle )
                        }
                    }
                }
            }

            function calculateAngle( point, initialAngle ) {
                let mapped =  mapToItem( parent, point.x, point.y )
                let origin = Qt.point( root.x + rect_originHandle.x + rect_originHandle.centerX,
                                       root.y + rect_originHandle.y + rect_originHandle.centerY)
                let diffX = mapped.x - origin.x
                let diffY = -1.0 * ( mapped.y - origin.y )
                let angle = toDegrees( Math.atan2( diffY, diffX ) - initialAngle )
                root.rotation = -angle
            }
        }
    }

    function calculateAngle( x, y ) {
        return Math.atan2( y, x )
    }

    function toDegrees( value ) {
        return value / Math.PI * 180.0
    }

    function toRadians( value ) {
        return value / 180 * Math.PI
    }

    function normalize( value, length ) {
        return value / length
    }

    function convertToNormalized( x, y, width, height ) {
        return {
            nx: normalize( x, width ),
            ny : normalize( y, height)
        }
    }

    function distance( x1, x2, y1, y2 ) {
        let dx = x2 - x1
        let dy = y2 - y1
        return Math.sqrt( Math.pow( dx, 2.0 ) + Math.pow( dy, 2.0 ) )
    }
}
