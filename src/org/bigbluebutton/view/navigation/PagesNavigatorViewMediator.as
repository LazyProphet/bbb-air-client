package org.bigbluebutton.view.navigation
{
	import mx.events.FlexEvent;
	
	import org.bigbluebutton.model.IUserUISession;
	import org.bigbluebutton.util.NoTransition;
	import org.bigbluebutton.view.navigation.pages.PagesENUM;
	import org.osmf.logging.Log;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;
	import spark.transitions.ViewTransitionBase;
	import spark.transitions.ViewTransitionDirection;

	public class PagesNavigatorViewMediator extends Mediator
	{
		[Inject]
		public var view: IPagesNavigatorView;
		
		[Inject]
		public var userSession: IUserUISession
		
		[Inject]
		public var userUISession: IUserUISession
		
		override public function initialize():void
		{
			Log.getLogger("org.bigbluebutton").info(String(this));
			
			userSession.pageChangedSignal.add(changePage);
			
			userUISession.pushPage(PagesENUM.LOGIN);
		}
		
		protected function changePage(pageName:String, pageRemoved:Boolean = false, transition:ViewTransitionBase = null):void
		{			
			if(pageRemoved)
			{
				if(transition == null) {
					var slideRight:SlideViewTransition = new SlideViewTransition();
					slideRight.duration = 300;
					slideRight.direction = ViewTransitionDirection.RIGHT;
					slideRight.addEventListener(FlexEvent.TRANSITION_START, onTransitionStart);
					transition = slideRight;
				}
				view.popView();
			}
			else if(pageName != null && pageName != "") 
			{
				if(transition == null) {
					var slideLeft:SlideViewTransition = new SlideViewTransition();
					slideLeft.duration = 300;
					slideLeft.direction = ViewTransitionDirection.LEFT;
					slideLeft.addEventListener(FlexEvent.TRANSITION_START, onTransitionStart);
					transition = slideLeft;
				}
				view.pushView(PagesENUM.getClassfromName(pageName), null, null, transition);
			}
		}
		
		protected function onTransitionStart(event:FlexEvent):void
		{
			// TODO Auto-generated method stub
			userUISession.pageTransitionStartSignal.dispatch(userUISession.lastPage);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			view.dispose();
			view = null;
		}
	}
}