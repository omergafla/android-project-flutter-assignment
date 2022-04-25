DRY PART


1. SnappingSheetController. the controller holds data (state) of the snapping sheet widget, mainly reagarding its snapping positions and allow to edit it and affect the SnappingSheet widget properties reflected on the user side. for example - currentPosition, SnapToPosition, setSnappingSheetFactor , isAttached, etc.

2. The snappingCurve, combined with snappingDuration  allows the developer to define the animoation feature along with its length, some examples values would be Ease-In-Out, elasticOut, BounceIn and other familiar motion design possibilities.


3. GestureDectector allows dragging unlike InkWell (which is gernealy more limited), and InkWell allow using "ripple" effect while GestureDetector isn't.
