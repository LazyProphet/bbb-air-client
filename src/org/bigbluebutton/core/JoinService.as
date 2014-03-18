package org.bigbluebutton.core
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import mx.graphics.shaderClasses.ExclusionShader;
	import mx.utils.ObjectUtil;
	
	import org.flexunit.internals.events.ExecutionCompleteEvent;
	import org.bigbluebutton.model.Config;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.bigbluebutton.core.util.URLFetcher;

	public class JoinService
	{
		protected var _successSignal:Signal = new Signal();
		protected var _unsuccessSignal:Signal = new Signal();
		
		public function get successSignal():ISignal {
			return _successSignal;
		}
		
		public function get unsuccessSignal():ISignal {
			return _unsuccessSignal;
		}
		
		public function join(joinUrl:String):void {
			if (joinUrl.length == 0) {
				onUnsuccess("emptyJoinUrl");
				return;
			}
			
			var fetcher:URLFetcher = new URLFetcher();
			fetcher.successSignal.add(onSuccess);
			fetcher.unsuccessSignal.add(onUnsuccess);
			fetcher.fetch(joinUrl);
		}
		
		protected function onSuccess(data:Object, responseUrl:String, urlRequest:URLRequest):void {
			try {
				var xml:XML = new XML(data);
				if (xml.returncode == "FAILED") {
					onUnsuccess(xml.messageKey);
					return;
				}
			} catch (e:Error) {
				trace("The response is probably not a XML, continuing");
			}
			successSignal.dispatch(urlRequest, responseUrl);
		}
		
		protected function onUnsuccess(reason:String):void {
			unsuccessSignal.dispatch(reason);
		}
	}
}