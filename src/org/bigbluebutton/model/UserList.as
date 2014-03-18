package org.bigbluebutton.model
{
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	
	import spark.collections.Sort;
	
	public class UserList
	{
		private var _users:ArrayCollection;	
		
		[Bindable]
		public function get users():ArrayCollection
		{
			return _users;
		}
		
		private function set users(value:ArrayCollection):void
		{
			_users = value;
		}
		
		private var _me:User;
		
		public function get me():User
		{
			return _me;
		}
		
		private function set me(value:User):void
		{
			_me = value;
		}
		
		private var _sort:Sort;
		
		public function UserList()
		{
			_me = new User();
			_users = new ArrayCollection();
			_sort = new Sort();
			_sort.compareFunction = sortFunction;
			_users.sort = _sort;
		}
		
		
		/**
		 * Dispatched when a participant is added
		 */
		private var _userAddedSignal: Signal = new Signal();
		
		public function get userAddedSignal(): ISignal
		{
			return _userAddedSignal;
		}
		
		
		/**
		 * Dispatched when a participant is removed
		 */
		private var _userRemovedSignal: Signal = new Signal();
		
		public function get userRemovedSignal(): ISignal
		{
			return _userRemovedSignal; 
		}
		
		/**
		 * Dispatched when a users' property have been changed
		 */
		private var _userChangeSignal: Signal = new Signal();
		
		public function get userChangeSignal():ISignal
		{
			return _userChangeSignal;
		}		
		
		/**
		 * Get a user based on a UserId 
		 * 
		 * @param UserId
		 */
		public function getUserByUserId(userId:String):User
		{
			if (users != null)
			{
				for each(var user:User in users)
				{	
					if (user.userID == userId)
					{
						return user;
					}
				}
			}
			
			return null;		
		}
		
		/** 
		 * Custom sort function for the users ArrayCollection. Need to put dial-in users at the very bottom.
		 */ 
		private function sortFunction(a:Object, b:Object, array:Array = null):int {
			var au:User = a as User, bu:User = b as User;
			/*if (a.presenter)
			return -1;
			else if (b.presenter)
			return 1;*/
			if (au.role == User.MODERATOR && bu.role == User.MODERATOR) {
				// do nothing go to the end and check names
			} else if (au.role == User.MODERATOR)
				return -1;
			else if (bu.role == User.MODERATOR)
				return 1;
			else if (au.raiseHand && bu.raiseHand) {
				// do nothing go to the end and check names
			} else if (au.raiseHand)
				return -1;
			else if (bu.raiseHand)
				return 1;
			else if (au.phoneUser && bu.phoneUser) {
				
			} else if (au.phoneUser)
				return -1;
			else if (bu.phoneUser)
				return 1;
			
			/** 
			 * Check name (case-insensitive) in the event of a tie up above. If the name 
			 * is the same then use userID which should be unique making the order the same 
			 * across all clients.
			 */
			if (au.name.toLowerCase() < bu.name.toLowerCase())
				return -1;
			else if (au.name.toLowerCase() > bu.name.toLowerCase())
				return 1;
			else if (au.userID.toLowerCase() > bu.userID.toLowerCase())
				return -1;
			else if (au.userID.toLowerCase() < bu.userID.toLowerCase())
				return 1;
			
			return 0;
		}
		
		public function addUser(newuser:User):void {
			trace("Adding new user [" + newuser.userID + "]");
			if (! hasUser(newuser.userID)) {
				trace("Am I this new user [" + newuser.userID + ", " + _me.userID + "]");
				if (newuser.userID == _me.userID) {
					newuser.me = true;
					//TODO check if this is correct
					// if we don't set _me to the just added user, _me won't get any update ever, it wouldn't be
					// possible to use me.isModerator(), for instance
					_me = newuser;
				}						
				
				newuser.signal = _userChangeSignal;
				_users.addItem(newuser);
				_users.refresh();
				
				userAddedSignal.dispatch(newuser);
			}					
		}
		
		public function hasUser(userID:String):Boolean {
			var p:Object = getUserIndex(userID);
			if (p != null) {
				return true;
			}
			
			return false;		
		}
		
		public function getUser(userID:String):User {
			var p:Object = getUserIndex(userID);
			if (p != null) {
				return p.participant as User;
			}
			
			return null;				
		}
		
		public function getUserByVoiceUserId(voiceUserId:Number):User {
			var aUser:User;
			
			for (var i:int = 0; i < _users.length; i++) {
				aUser = _users.getItemAt(i) as User;
				
				if (aUser.voiceUserId == voiceUserId) {
					return aUser;
				}
			}				
			
			return null;
		}
		
		public function removeUser(userID:String):void {
			var p:Object = getUserIndex(userID);
			if (p != null) 
			{
				var user:User = p.participant as User; 
				user.isLeavingFlag = true;
				
				trace("removing user[" + user.name + "," + user.userID + "]");				
				_users.removeItemAt(p.index);
				_users.refresh();
				
				userRemovedSignal.dispatch(userID);
			}							
		}
		
		/**
		 * Get the presenter user 
		 * @return null if participant not found
		 * 
		 */	
		public function getPresenter():User {
			var u:User;
			for (var i:int = 0; i < _users.length; i++) {
				u = _users.getItemAt(i) as User;				
				if (u.presenter)
					return u;
			}
			return null;
		}
		
		public function removePresenter(userID:String):void {
			var u:User = getPresenter();
			if (u.presenter) {
				u.presenter = false;
				
				userChangeSignal.dispatch(u);
				
				if (u.me)
					_me.presenter = false;
			}
		}
		
		public function assignPresenter(userID:String):void 
		{
			clearPresenter();			
			
			var p:Object = getUserIndex(userID);
			if (p) {
				var user:User = p.participant as User;
				
				user.presenter = true;
				
				userChangeSignal.dispatch(user);
				
				if (user.me)
					_me.presenter = true;
			}
		}

		private function clearPresenter():void
		{
			for each(var user:User in _users)
			{
				user.presenter = false;
			}
		}
		
		public function userStreamChange(userID:String, hasStream:Boolean, streamName:String):void {
			var p:Object = getUserIndex(userID);
			
			if (p) {
				p.participant.hasStream = hasStream;
				p.participant.streamName = streamName;
				
				if (p.participant.me)
					_me.hasStream = hasStream;
				
				userChangeSignal.dispatch(p.participant, "hasStream");
			}
		}
		
		public function raiseHandChange(userID:String, value:Boolean):void {
			var p:Object = getUserIndex(userID);
			
			if (p) {
				p.participant.raiseHand = value;
				
				userChangeSignal.dispatch(p.participant);
				
				if (p.participant.me)
					_me.raiseHand = value;
			}
		}
		
		/**
		 * Get the index number of the participant with the specific userid 
		 * @param userid
		 * @return -1 if participant not found
		 * 
		 */		
		private function getUserIndex(userID:String):Object {
			var aUser:User;
			
			for (var i:int = 0; i < _users.length; i++) {
				aUser = _users.getItemAt(i) as User;
				
				if (aUser.userID == userID) {
					return {index:i, participant:aUser};
				}
			}				
			
			return null;
		}
	}
}