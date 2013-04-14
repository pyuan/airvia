package com.utils
{
	public class StringUtil
	{
		
		public static function stringToDate(date:String):Date
		{
			var dateArray:Array = date.split("/");
			var y:Number = Number(dateArray[0]);
			var m:Number = Number(dateArray[1]) - 1;
			var d:Number = Number(dateArray[2]);
			var h:Number = Number(dateArray[3]);
			var mi:Number = Number(dateArray[4]);
			var returnDate:Date = new Date(y, m, d, h, mi);
			return returnDate;
		}
		
		public static function formatDoubleDigits(number:Number):String
		{
			var r:String = "";
			if(number < 10){
				r = "0" + number;
			}
			else{
				r = String(number);
			}
			return r;
		}
		
		public static function getMonthString(m:Number):String
		{
			var month:String = "";
			switch(m){
				case 1:
					month = "January";
					break;
				case 2:
					month = "Feburary";
					break;
				case 3:
					month = "March";
					break;
				case 4:
					month = "April";
					break;
				case 5:
					month = "May";
					break;
				case 6:
					month = "June";
					break;
				case 7:
					month = "July";
					break;
				case 8:
					month = "August";
					break;
				case 9:
					month = "September";
					break;
				case 10:
					month = "October";
					break;
				case 11:
					month = "November";
					break;
				case 12:
					month = "December";
					break;
			}
			return month;
		}

	}
}