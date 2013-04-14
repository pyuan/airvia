package com
{
	public class Constants
	{
		/**** App Constants ****/
		/*Design Dependent*/ public static const COORD_XML_PATH : String = 'assets/coordinates.xml';
		/*Design Dependent*/ public static const TRACKING_TIMER_UPDATE_INTERVAL : int = 1000; //ms
		
		/**** Map Constants ****/
		/*Design Dependent*/ public static const LINE_COLOR : uint = 0xffd800;
		/*Design Dependent*/ public static const LINE_THICKNESS : int = 2;
		/*Design Dependent*/ public static const DOT_BLINK_ALPHA : Number = 0.5;
		/*Design Dependent*/ public static const DOT_BLINK_TIME : Number = 1; //in s
		
		/**** Zoom Constants ****/
		/*Design Dependent*/ public static const ZOOM_FACTOR : int = 1;
		/*Design Dependent*/ public static const ZOOM_TIME : Number = 0.75; //in s
		/*Design Dependent*/ public static const ZOOM_LEVEL_MAX : int = 10;
		/*Design Dependent*/ public static const ZOOM_LEVEL_MIN : int = 1;
		
		/**** Tooltip Constants ****/
		/*Design Dependent*/ public static const TOOLTIP_MODE_ME : String = "tooltipModeMe";
		/*Design Dependent*/ public static const TOOLTIP_MODE_LOCATION : String = "tooltipModeLocation";
		
		/**** Modal Constants ****/
		/*Design Dependent*/ public static const MODAL_MODE_DATEPICKER : String = "modalModeDate";
		
		/**** Picture Viewer Constants ****/
		/*Design Dependent*/ public static const PICTURE_VIEWER_TIME_INTERVAL : int = 3000; //ms
		/*Design Dependent*/ public static const PICTURE_VIEWER_IMAGE_WIDTH : int = 330;
		/*Design Dependent*/ public static const PICTURE_VIEWER_IMAGE_HEIGHT : int = 135;

	}
}