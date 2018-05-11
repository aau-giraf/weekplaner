﻿using IO.Swagger.Api;
using IO.Swagger.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using WeekPlanner.Helpers;
using WeekPlanner.Services;
using WeekPlanner.Services.Navigation;
using WeekPlanner.Services.Request;
using WeekPlanner.Validations;
using Xamarin.Forms;

namespace WeekPlanner.ViewModels
{
    public class NewScheduleViewModel : Base.ViewModelBase
    {
        private WeekDTO _weekDTO = new WeekDTO();

        private readonly IWeekApi _weekApi;
        private readonly IPictogramApi _pictogramApi;
        private readonly IDialogService _dialogService;
        private readonly IRequestService _requestService;

        private ValidatableObject<string> _scheduleName;

        public ValidatableObject<string> ScheduleName
        {
            get => _scheduleName;
            set
            {
                _scheduleName = value;
                RaisePropertyChanged(() => ScheduleName);
            }
        }

        private WeekPictogramDTO _weekThumbNail;

        public WeekPictogramDTO WeekThumbNail
        {
            get => _weekThumbNail;
            set
            {
                _weekThumbNail = value;
                RaisePropertyChanged(() => WeekThumbNail);
            }
        }

        private const int NumberOfWeeksToChooseFrom = 5;
        
        private List<(int,int)> _yearsAndWeeks = Enumerable.Range(
            DateTimeHelper.GetIso8601WeekOfYear(DateTime.Now),
            NumberOfWeeksToChooseFrom).Select(WeekToYearsAndWeeks).ToList();

        private static (int,int) WeekToYearsAndWeeks(int week)
        {
            var year = DateTime.Now.Year;
            return week > 52 
                ? (year + 1, week + 1 % 53) 
                : (year, week);
        }
        public List<string> YearsAndWeeksStrings
        {
            get => _yearsAndWeeks.Select(yw => $"Uge {yw.Item2} - {yw.Item1}").ToList();
        }
        
        public int SelectedYearWeekIndex { get; set; }

        public ICommand SaveWeekScheduleCommand => new Command(SaveWeekSchedule);
        public ICommand ChangePictogramCommand => new Command(ChangePictogram);

        public NewScheduleViewModel(
            INavigationService navigationService,
            IWeekApi weekApi,
            IPictogramApi pictogramApi,
            IRequestService requestService,
            IDialogService dialogService) : base(navigationService)
        {
            _weekApi = weekApi;
            _pictogramApi = pictogramApi;
            _requestService = requestService;
            _dialogService = dialogService;

            _scheduleName =
                new ValidatableObject<string>(
                    new IsNotNullOrEmptyRule<string> {ValidationMessage = "Et navn er påkrævet."});
        }

        public async override Task InitializeAsync(object navigationData)
        {
            await _requestService.SendRequestAndThenAsync(
                requestAsync: async () => await _pictogramApi.V1PictogramByIdGetAsync(2),
                onSuccess: result =>
                {
                    PictogramDTO defaultPicto = result.Data;
                    WeekPictogramDTO weekPictogramDto = new WeekPictogramDTO(defaultPicto.Id);
                    WeekThumbNail = weekPictogramDto;
                },
                onExceptionAsync: () => NavigationService.PopAsync(),
                onRequestFailedAsync: () => NavigationService.PopAsync());
        }

        public override Task PoppedAsync(object navigationData)
        {
            // Happens when selecting a picto in PictoSearch
            if (navigationData is PictogramDTO pictoDTO)
            {
                WeekThumbNail = PictoToWeekPictoDtoHelper.Convert(pictoDTO);
            }

            return Task.FromResult(false);
        }


        private void ChangePictogram()
        {
            if (IsBusy) return;
            IsBusy = true;
            NavigationService.NavigateToAsync<PictogramSearchViewModel>();
            IsBusy = false;
        }


        private async void SaveWeekSchedule()
        {
            if (IsBusy) return;
            IsBusy = true;

            if (ValidateWeekScheduleName())
            {
                _weekDTO.Name = ScheduleName.Value;
                _weekDTO.Thumbnail = WeekThumbNail;
                _weekDTO.Days = new List<WeekdayDTO>
                {
                    new WeekdayDTO(WeekdayDTO.DayEnum.Monday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Tuesday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Wednesday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Thursday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Friday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Saturday),
                    new WeekdayDTO(WeekdayDTO.DayEnum.Sunday)
                };

                await _requestService.SendRequestAndThenAsync(
                    requestAsync: () =>
                        _weekApi.V1WeekByWeekYearByWeekNumberPutAsync(
                            weekNumber: _yearsAndWeeks[SelectedYearWeekIndex].Item2,
                            weekYear: _yearsAndWeeks[SelectedYearWeekIndex].Item1, 
                            newWeek: _weekDTO),
                    onSuccess:
                    async result =>
                    {
                        await _dialogService.ShowAlertAsync($"Ugeplanen '{result.Data.Name}' blev oprettet og gemt.");
                        await NavigationService.PopAsync();
                    });
            }

            IsBusy = false;
        }

        public ICommand ValidateWeekNameCommand => new Command(() => _scheduleName.Validate());

        private bool ValidateWeekScheduleName()
        {
            var isWeekNameValid = _scheduleName.Validate();
            return isWeekNameValid;
        }
    }
}