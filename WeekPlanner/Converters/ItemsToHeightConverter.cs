﻿using System;
using System.Globalization;
using Xamarin.Forms;

namespace WeekPlanner.Converters
{
    public class ItemsToHeightConverter : IValueConverter
    {
        // TODO: Can we do this smarter?
        private const int ItemHeight = 100;

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value is int)
            {
                return System.Convert.ToInt32(value) * ItemHeight;
            }

            return 0;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return null;
        }
    }
}
