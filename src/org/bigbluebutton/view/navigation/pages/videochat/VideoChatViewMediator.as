package org.bigbluebutton.view.navigation.pages.videochat
{
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.bigbluebutton.model.IUserSession;
	import org.bigbluebutton.model.IUserUISession;
	import org.bigbluebutton.model.User;
	import org.bigbluebutton.model.UserSession;
	import org.bigbluebutton.view.navigation.pages.PagesENUM;
	import org.mockito.integrations.currentMockito;
	import org.osmf.logging.Log;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class VideoChatViewMediator extends Mediator
	{
		[Inject]
		public var view: IVideoChatView;
		
		[Inject]
		public var userSession: IUserSession;
		
		[Inject]
		public var userUISession: IUserUISession;
		
		override public function initialize():void
		{
			Log.getLogger("org.bigbluebutton").info(String(this));
			
			userSession.userList.userRemovedSignal.add(userRemovedHandler);
			userSession.userList.userAddedSignal.add(userAddedHandler);
			userSession.userList.userChangeSignal.add(userChangeHandler);
			
			userUISession.pageTransitionStartSignal.add(onPageTransitionStart);
			
			// find all currently open streams
			//var users:ArrayCollection = userSession.userlist.users;
			//for (var i:Number=0; i < users.length; i++) {
			//	var u:User = users.getItemAt(i) as User;
			//	if (u.hasStream) {
			//		startStream(u.name, u.streamName);
			//	}
			//}
			
			checkVideo();
		}
		
		protected function getUserWithCamera():User
		{
			var users:ArrayCollection = userSession.userList.users;
			for each(var u:User in users) 
			{
				if (u.hasStream) {
					return u;
				}
			}
			return null;
		}
				
		private function onPageTransitionStart(lastPage:String):void
		{
			if(lastPage == PagesENUM.VIDEO_CHAT)
			{
				view.dispose();
			}
		}
		
		override public function destroy():void
		{
			userSession.userList.userRemovedSignal.remove(userRemovedHandler);
			userSession.userList.userAddedSignal.remove(userAddedHandler);
			userSession.userList.userChangeSignal.remove(userChangeHandler);
			
			userUISession.pageTransitionStartSignal.remove(onPageTransitionStart);
			
			view.dispose();
			view = null;
			
			super.destroy();
		}
		
		private function userAddedHandler(user:User):void {
			if (user.hasStream)
				checkVideo();
		}
		
		private function userRemovedHandler(userID:String):void {
			if (view.getDisplayedUserID() == userID) {
				stopStream(userID);
				checkVideo();
			}
		}
		
		private function userChangeHandler(user:User, property:String = null):void {
			if (property == "hasStream") {
				if (user.userID == view.getDisplayedUserID() && !user.hasStream) {
					stopStream(user.userID);
				}
				checkVideo();
			}
		}
		
		private function startStream(name:String, streamName:String):void {
			var resolution:Object = getVideoResolution(streamName);
			
			if (resolution) {
				trace(ObjectUtil.toString(resolution));
				var width:Number = Number(String(resolution.dimensions[0]));
				var length:Number = Number(String(resolution.dimensions[1]));
				if (view) 
				{
					view.startStream(userSession.videoConnection.connection, name, streamName, resolution.userID, width, length);
				}
			}
		}
		
		private function stopStream(userID:String):void {
			if (view) {
				view.stopStream();
			}
		}
		
		private function checkVideo():void {
			var currentUserID:String = view.getDisplayedUserID();
			
			var selectedUser:User = userUISession.currentPageDetails as User;
			var presenter:User = userSession.userList.getPresenter();
			var userWithCamera:User = getUserWithCamera();
			var newUser:User;
			
			if (selectedUser && selectedUser.hasStream)
			{
				newUser = selectedUser;
			}
			else if (presenter != null && presenter.hasStream)
			{
				newUser = presenter;
			}
			else if (currentUserID != null) {
				return;
			}
			else if (userWithCamera != null)
			{
				newUser = userWithCamera;
			}
			else
			{
				view.noVideoMessage.visible = true;
				return;
			}
			
			view.noVideoMessage.visible = false;
			if (newUser.userID != currentUserID) {
				if (view) view.stopStream();
				
				startStream(newUser.name, newUser.streamName);
			}
		}
		
		protected function getVideoResolution(stream:String):Object {
			var pattern:RegExp = new RegExp("(\\d+x\\d+)-([A-Za-z0-9]+)-\\d+", "");
			if (pattern.test(stream)) {
				trace("The stream name is well formatted [" + stream + "]");
				trace("Stream resolution is [" + pattern.exec(stream)[1] + "]");
				trace("Userid [" + pattern.exec(stream)[2] + "]");
				return {userID: pattern.exec(stream)[2], dimensions:pattern.exec(stream)[1].split("x")};
			} else {
				trace("The stream name doesn't follow the pattern <width>x<height>-<userId>-<timestamp>. However, the video resolution will be set to 320x240");
				return null;
			}
		}
	}
}