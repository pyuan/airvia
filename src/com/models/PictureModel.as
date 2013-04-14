package com.models
{
	[Bindable]
	public class PictureModel
	{
		
		public var url:String = "";
		
		public var caption:String = "";
		
		public function PictureModel(url:String, caption:String="")
		{
			this.url = url;
			this.caption = caption;
		}

	}
}