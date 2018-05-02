﻿using IO.Swagger.Model;

namespace WeekPlanner.Services.Settings
{
    public interface ISettingsService
    {
        string BaseEndpoint { get; set; }
        bool UseMocks { get; set; }
        string GuardianAuthToken { get; set; }
        string CitizenAuthToken { get; set; }
        void UseTokenFor(UserType userType);
        Task UpdateSettings(SettingDTO settings);

    }


    public enum UserType
    {
        Citizen,
        Guardian
    }
}