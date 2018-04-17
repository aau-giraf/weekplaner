﻿using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.OS;
using FFImageLoading.Forms.Droid;
using Xamarin.Forms;
using WeekPlanner.Views;

namespace WeekPlanner.Droid
{
    [Activity(Label = "WeekPlanner.Droid", Icon = "@drawable/icon", Theme = "@style/MyTheme", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation, ScreenOrientation = ScreenOrientation.Landscape)]
    public class MainActivity : global::Xamarin.Forms.Platform.Android.FormsAppCompatActivity
    {
        protected override void OnCreate(Bundle bundle)
        {
            TabLayoutResource = Resource.Layout.Tabbar;
            ToolbarResource = Resource.Layout.Toolbar;

			MessagingCenter.Subscribe<WeekPlannerPage>(this, "allowPortrait", (sender) =>
			{
				RequestedOrientation = ScreenOrientation.Unspecified;
			});

			MessagingCenter.Subscribe<WeekPlannerPage>(this, "forceLandscape", (sender) =>
			{
				RequestedOrientation = ScreenOrientation.Landscape;
			});

			base.OnCreate(bundle);

			Forms.Init(this, bundle);
            CachedImageRenderer.Init(enableFastRenderer: true);
            LoadApplication(new App());
        }

        protected override void OnActivityResult(int requestCode, Result resultCode, Intent data)
        {
            base.OnActivityResult(requestCode, resultCode, data);
        }
    }
}
