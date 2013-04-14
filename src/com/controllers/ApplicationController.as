package com.controllers
{
	import caurina.transitions.Tweener;
	
	import com.Constants;
	import com.models.CoordModel;
	import com.models.Model;
	import com.models.PictureModel;
	import com.utils.StringUtil;
	import com.views.LocationDot;
	import com.views.MyDot;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.formatters.CurrencyFormatter;
	
	public class ApplicationController
	{
		public static const SINGLETON:ApplicationController = new ApplicationController();
		
		public var model:Model;
		
		private var app:AirVIA;
		
		private var trackingTimer:Timer;
		
		private var originalMouseX:Number = -1;
		
		private var originalMouseY:Number = -1;
		
		public function ApplicationController()
		{
			if(ApplicationController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using ApplicationController.SINGLETON.");
		}
		
		public function init(app:AirVIA):void
		{
			trace('Application Contoller initialized');
			this.app = app;
			model = new Model();
			getCoords();
			showDatePicker();
		}
		
		public function showDatePicker():void
		{
			app.modal.show(Constants.MODAL_MODE_DATEPICKER);
		}
		
		public function hideModal():void
		{
			app.modal.hide();
		}
		
		private function getCoords():void
		{
			trace('loading coordinates xml');
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, setCoords);
			loader.addEventListener(IOErrorEvent.IO_ERROR, function():void{trace('No connection could be made to the xml file.');});
			loader.load(new URLRequest(Constants.COORD_XML_PATH));
		}
		
		private function setCoords(e:Event):void
		{
			model.coordinates.removeAll();
			var xml:XML = new XML(e.currentTarget.data);
			
			//get map url
			if(xml.map.length() > 0){
				model.mapUrl = xml.map[0];
				trace("Setting map url: " + model.mapUrl);
				loadMap();
			}
			
			//get base date
			if(xml.baseDate.length() > 0){
				model.baseDate = StringUtil.stringToDate(xml.baseDate[0]);
				trace("Setting start date: " + model.baseDate);
			}
			
			//get coordinates
			if(xml.point.length() > 0){
				for(var i:int=0; i<xml.point.length(); i++){
					var name:String = xml.point[i].name[0];
					var date:String = xml.point[i].date[0];
					var pos:String = xml.point[i].pos[0];
					var point:CoordModel = new CoordModel(name, date, pos);
					
					//add images
					if(xml.point[i].picture.length() > 0){
						for(var j:int=0; j<xml.point[i].picture.length(); j++){
							var url:String = "";
							var caption:String = "";
							if(xml.point[i].picture[j].url.length() > 0){
								url = xml.point[i].picture[j].url[0];
							}
							if(xml.point[i].picture[j].caption.length() > 0){
								caption = xml.point[i].picture[j].caption[0];
							}
							var picture:PictureModel = new PictureModel(url, caption);
							point.pictures.addItem(picture);
						}
					}
					
					model.coordinates.addItem(point);
				}			
			}
			
			app.modal.datePicker.init();
		}
		
		private function loadMap():void
		{
			app.map.map.source = model.mapUrl;
			trace("Map loaded: " + model.mapUrl);
		}
		
		public function startTracking():void
		{
			drawDots();
			trace('Tracking timer starting...');
			if(!trackingTimer){
				trackingTimer = new Timer(Constants.TRACKING_TIMER_UPDATE_INTERVAL);
				trackingTimer.addEventListener(TimerEvent.TIMER, onTrackingTimerUpdate);
				trackingTimer.start();
				
				//set default dot position
				var e:TimerEvent = new TimerEvent(TimerEvent.TIMER);
				onTrackingTimerUpdate(e);
			}
		}
		
		private function stopTracking():void
		{
			trace('Tracking timer stopping...');
			if(trackingTimer){
				trackingTimer.stop();
				trackingTimer.removeEventListener(TimerEvent.TIMER, onTrackingTimerUpdate);
			}
		}
		
		private function onTrackingTimerUpdate(e:TimerEvent):void
		{
			//get start time
			var startDate:Date = model.baseDate;
			var start:Number = Date.UTC(startDate.fullYearUTC, startDate.monthUTC, startDate.dateUTC, startDate.hoursUTC, startDate.minutesUTC, startDate.secondsUTC);
			
			//get difference to end time
			var endDate:Date = CoordModel(model.coordinates[model.coordinates.length-1]).date;
			var end:Number = Date.UTC(endDate.fullYearUTC, endDate.monthUTC, endDate.dateUTC, endDate.hoursUTC, endDate.minutesUTC);
			var diff:Number = end - start;
			
			//update dot position
			var index:int = getNextPointIndex(new Date());
			if(index == 0){
				var dotPos:Point = model.coordinates[model.fromStationIndex].pos;
			}
			else if(index < model.coordinates.length-1){
				dotPos = getDotPosition(index);
			}
			else{
				dotPos = model.coordinates[model.toStationIndex].pos;
			}
			updateDot(dotPos); 
			
			//update time display
			updateTime();
		}
		
		private function getNextPointIndex(current:Date):int
		{
			var startMs:Number = Date.UTC(model.startDate.fullYearUTC, model.startDate.monthUTC, model.startDate.dateUTC, model.startDate.hoursUTC, model.startDate.minutesUTC);
			var currentInMs:Number = Date.UTC(current.fullYearUTC, current.monthUTC, current.dateUTC, current.hoursUTC, current.minutesUTC, current.secondsUTC);
			var elapsedMs:Number = currentInMs - startMs;
			
			for(var i:int=0; i<=model.coordinates.length-1; i++){
				var point:CoordModel = model.coordinates[i];
				var pointInMs:Number = point.time;
				if(elapsedMs < pointInMs){
					break;
				}
			}
			
			if(i < model.coordinates.length){
				trace("Next destination is: " + model.coordinates[i].name);
			}
			return i;
		}
		
		private function getDotPosition(nextPointIndex:int):Point
		{
			//get two points
			var pointA:Point, pointB:Point;
			if(nextPointIndex > model.toStationIndex){
				pointB = (model.coordinates[model.toStationIndex] as CoordModel).pos;
				pointA = pointB;
				nextPointIndex = model.toStationIndex;
			}
			else{
				pointB = (model.coordinates[nextPointIndex] as CoordModel).pos;
				if(nextPointIndex == 0){
					pointA = pointB;
				}
				else{
					pointA = (model.coordinates[nextPointIndex - 1] as CoordModel).pos;
				}
			}
			
			//calculate distance between two points
			var sideX:Number = pointB.x - pointA.x;
			var sideY:Number = pointB.y - pointA.y;
			var distance:Number = Math.sqrt(Math.pow(sideX, 2) + Math.pow(sideY, 2));
			
			//calculate percentage travelled based on time
			var startTimeMs:Number = Date.UTC(model.startDate.fullYearUTC, model.startDate.monthUTC, model.startDate.dateUTC, model.startDate.hoursUTC, model.startDate.minutesUTC);
			var lastPointIndex:int = nextPointIndex>0 ? nextPointIndex-1 : nextPointIndex;
			var lastPointMs:Number = model.coordinates[lastPointIndex].time;
			var today:Date = new Date();
			var now:Number = Date.UTC(today.fullYearUTC, today.monthUTC, today.dateUTC, today.hoursUTC, today.minutesUTC, today.secondsUTC) - lastPointMs - startTimeMs;
			var dt:Number = model.coordinates[nextPointIndex].time - lastPointMs;
			var pct:Number = now / dt;
			
			var disTravelled:Number = distance * pct;
			var ptY:Number = pointA.y + (pointB.y - pointA.y) * pct;
			var ptX:Number = pointA.x + (pointB.x - pointA.x) * pct;
			var point:Point = new Point(ptX, ptY);
			trace("Point is :" + point + "| Percentage travelled from last point: " + Math.round(pct*100) + "%");
			return point;
		}	
			
		private function updateDot(pos:Point):void
		{
			trace("Moving my dot...");
			if(app.map.myDot.numChildren == 0){
				var me:MyDot = new MyDot();
				me.x = pos.x - me.width/2;
				me.y = pos.y - me.height/2;
				app.map.myDot.addChild(me);
			}
			else{
				me = MyDot(app.map.myDot.getChildAt(0));
				me.x = pos.x - me.width/2;
				me.y = pos.y - me.height/2;
			}
		}
		
		private function drawDots():void
		{
			app.map.dotsCanvas.removeAllChildren();
			for(var i:int = model.fromStationIndex; i <= model.toStationIndex; i++){
				var coordModel:CoordModel = model.coordinates[i] as CoordModel;
				var dot:LocationDot = new LocationDot();
				dot.coordModel = coordModel;
				dot.x = coordModel.pos.x - dot.width/2;
				dot.y = coordModel.pos.y - dot.height/2;
				app.map.dotsCanvas.addChild(dot);
			}
			drawLines();
		}
		
		private function drawLines():void
		{
			app.map.dotsCanvas.graphics.clear();
			app.map.dotsCanvas.graphics.lineStyle(Constants.LINE_THICKNESS, Constants.LINE_COLOR);
			for(var i:int = model.fromStationIndex; i <= model.toStationIndex; i++){
				if(i != model.fromStationIndex){
					var endPt:Point = CoordModel(model.coordinates[i]).pos;
					var startPt:Point = CoordModel(model.coordinates[i-1]).pos;
					app.map.dotsCanvas.graphics.moveTo(startPt.x, startPt.y);
					app.map.dotsCanvas.graphics.lineTo(endPt.x, endPt.y);
				}
			}
			app.map.dotsCanvas.graphics.endFill();
		}
		
		private function updateTime():void
		{
			var today:Date = new Date();
			var now:Number = Date.UTC(today.fullYearUTC, today.monthUTC, today.dateUTC, today.hoursUTC, today.minutesUTC, today.secondsUTC);
			var destination:CoordModel = model.coordinates[model.toStationIndex];
			var startTimeMs:Number = Date.UTC(model.startDate.fullYearUTC, model.startDate.monthUTC, model.startDate.dateUTC, model.startDate.hoursUTC, model.startDate.minutesUTC);
			var dt:Number = destination.time + startTimeMs;
			var remainMs:Number = dt - now;
			var remainS:Number = remainMs/1000;
			var formatter:CurrencyFormatter = new CurrencyFormatter();
			formatter.currencySymbol = "";
			var formattedTime:String = formatter.format(remainS);
			
			if(now < startTimeMs){
				app.gui.timeRemaining = "Your trip starts in " + formatter.format((startTimeMs - now)/1000) + " seconds.";
			}
			else if(remainMs > 0){
				app.gui.timeRemaining = "Only " + formattedTime + " seconds remaning until "  + destination.name + ".";
			}
			else{
				app.gui.timeRemaining = "You have arrived in " + destination.name + "!";
			}
		}
		
		public function zoomIn():void
		{
			if(app.map.scaleX < Constants.ZOOM_LEVEL_MAX && !Tweener.isTweening(app.map)){
				var newScaleX:Number = app.map.scaleX + Constants.ZOOM_FACTOR;
				var newScaleY:Number = app.map.scaleY + Constants.ZOOM_FACTOR;
				Tweener.addTween(app.map, {scaleX: newScaleX, scaleY: newScaleY, time: Constants.ZOOM_TIME, transition: 'linear'});
				trace("Zooming in to: " + app.map.scaleX);
			}
		}
		
		public function zoomOut():void
		{
			if(app.map.scaleX > Constants.ZOOM_LEVEL_MIN && !Tweener.isTweening(app.map)){
				var newScaleX:Number = app.map.scaleX - Constants.ZOOM_FACTOR;
				var newScaleY:Number = app.map.scaleY - Constants.ZOOM_FACTOR;
				Tweener.addTween(app.map, {scaleX: newScaleX, scaleY: newScaleY, time: Constants.ZOOM_TIME, transition: 'linear', 
					onComplete: alignMap});
				trace("Zooming out to: " + app.map.scaleX);
			}
		}
		
		public function resetZoom():void
		{
			Tweener.addTween(app.map, {scaleX: 1, scaleY: 1, time: 0.5, transition: 'linear'});
			alignMap();
		}
		
		//reposition map after zooming
		private function alignMap():void
		{
			Tweener.addTween(app.map, {x: 0/*posX*/, y: 0/*posY*/, time: 0.25, transition: 'linear'});
		}
		
		public function showPictureViewer(dot:Canvas):void
		{
			trace("Showing picture viewer...");
			app.map.pictureViewer.show(LocationDot(dot).coordModel);
			app.map.pictureViewer.visible = true;
			Tweener.removeTweens(app.map.pictureViewer);
			
			var posX:Number = app.map.viaTip.x - app.map.pictureViewer.width - 10;
			if(posX < 10){
				posX = app.map.viaTip.x + 10;
			}
			
			var posY:Number = dot.y - app.map.pictureViewer.height;
			if(posY < 10){
				posY = dot.y + 10;
			}
			if(posY + app.map.pictureViewer.height > app.height - 60){
				posY = app.height - 60 - app.map.pictureViewer.height;
			}
			
			app.map.pictureViewer.x = posX;
			app.map.pictureViewer.y = posY;
			Tweener.addTween(app.map.pictureViewer, {alpha: 1, delay: 0.5, time: 0.25, transition: 'linear'});
		}
		
		public function hidePictureViewer():void
		{
			trace("Hiding picture viewer...");
			app.map.pictureViewer.hide();
			Tweener.removeTweens(app.map.pictureViewer);
			Tweener.addTween(app.map.pictureViewer, {alpha: 0, time: 0.15, transition: 'linear', 
				onComplete: function():void{app.map.pictureViewer.visible = false;}});
		}
		
		public function pictureViewerNext():void
		{
			app.map.pictureViewer.next();
		}
		
		public function showTooltip(dot:Canvas, mode:String):void
		{
			trace("Showing tooltip...");
			app.map.viaTip.visible = true;
			
			app.map.viaTip.mode = mode;
			if(mode == Constants.TOOLTIP_MODE_LOCATION){
				app.map.viaTip.coordModel = LocationDot(dot).coordModel;
			}
			
			var posX:Number = dot.x + dot.width;
			if(posX + app.map.viaTip.width + 10 > app.width){
				posX = dot.x - app.map.viaTip.width;
			}
			app.map.viaTip.x = posX;
			
			var posY:Number = dot.y - app.map.viaTip.height;
			if(posY < 10){
				posY = dot.y + app.map.viaTip.height;
			}
			app.map.viaTip.y = posY;
			Tweener.addTween(app.map.viaTip, {alpha: 1, time: 0.25, transition: 'linear'});
		}
		
		public function hideTooltip():void
		{
			trace("Hiding tooltip...");
			Tweener.addTween(app.map.viaTip, {alpha: 0, time: 0.15, transition: 'linear', 
				onComplete: function():void{app.map.viaTip.visible = false;}});
		}
		
		public function startMoveMap(e:MouseEvent):void
		{
			originalMouseX = e.stageX;
			originalMouseY = e.stageY;
			trace("Register mouse click location: " + originalMouseX + "|" + originalMouseY);
			app.map.addEventListener(MouseEvent.MOUSE_MOVE, moveMap);
		}
		
		private function moveMap(e:MouseEvent):void
		{
			var newMouseX:Number = e.stageX;
			var newMouseY:Number = e.stageY;
			var diffX:Number = newMouseX - originalMouseX;
			var diffY:Number = newMouseY - originalMouseY;
			var newPosX:Number = app.map.x + diffX;
			var newPosY:Number = app.map.y + diffY;
			
			if((newPosX <= 0 && newPosX >= -(app.map.width-app.width)) &&
				(newPosY <= 0 && newPosY >= -(app.map.height-app.height))){
				Tweener.addTween(app.map, {x: newPosX, y: newPosY, time: 0.5, transition: 'easeOutQuart'});
				trace("Moving mouse to: " + newMouseX + "|" + newMouseY);
			}
		}
		
		public function stopMoveMap(e:MouseEvent):void
		{
			trace("Stop moving map");
			app.map.removeEventListener(MouseEvent.MOUSE_MOVE, moveMap);
		}

	}
}