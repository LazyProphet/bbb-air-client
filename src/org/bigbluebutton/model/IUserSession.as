package org.bigbluebutton.model
{
	import flash.net.NetConnection;
	
	import org.bigbluebutton.core.IBigBlueButtonConnection;
	import org.bigbluebutton.core.IVideoConnection;
	import org.bigbluebutton.core.IVoiceConnection;
	import org.bigbluebutton.core.VideoConnection;
	import org.bigbluebutton.core.VoiceStreamManager;
	import org.bigbluebutton.model.chat.ChatMessages;
	import org.bigbluebutton.model.presentation.PresentationList;
	import org.osflash.signals.ISignal;
	

	public interface IUserSession
	{
		function get netconnection():NetConnection;
		function set netconnection(value:NetConnection):void;
		function get config():Config;
		function set config(value:Config):void;
		function get userId():String;
		function set userId(value:String):void;		
		function get userList():UserList
		function get voiceConnection():IVoiceConnection
		function set voiceConnection(value:IVoiceConnection):void
		function get mainConnection():IBigBlueButtonConnection
		function set mainConnection(value:IBigBlueButtonConnection):void
		function get voiceStreamManager():VoiceStreamManager
		function set voiceStreamManager(value:VoiceStreamManager):void
		function get videoConnection():IVideoConnection
		function set videoConnection(value:IVideoConnection):void
		function get presentationList():PresentationList
		function get guestSignal():ISignal
	}
}