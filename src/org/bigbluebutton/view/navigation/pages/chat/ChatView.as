package org.bigbluebutton.view.navigation.pages.chat
{
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextInput;
	
	public class ChatView extends ChatViewBase implements IChatView
	{
		
		
		public function get list():List
		{
			return chatlist;
		}
		
		public function get inputMessage():TextInput
		{
			return inputMessage0;
		}
		
		public function get sendButton():Button
		{
			return sendButton0;
		}
		
		public function get pageTitle():Label
		{
			return pageTitle0;
		}
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			//this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function onClick(e:MouseEvent):void
		{
			//buttonTestSignal.dispatch();
		}

		public function dispose():void
		{
			
		}

	}
}