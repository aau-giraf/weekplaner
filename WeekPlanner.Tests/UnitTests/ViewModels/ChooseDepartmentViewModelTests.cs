using AutoFixture;
using IO.Swagger.Model;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using WeekPlanner.ViewModels;
using Xunit;
using Moq;
using IO.Swagger.Api;
using System.Linq;

namespace WeekPlanner.Tests.UnitTests.ViewModels
{
    public class ChooseDepartmentViewModelTests : ViewModelTestsBase
    {
        [Fact]
        public void DepartmentsProperty_OnSet_RaisePropertyChanged()
        {
            // Arrange
            var sut = Fixture.Create<ChooseDepartmentViewModel>();

            bool invoked = false;
            sut.PropertyChanged += (sender, e) =>
            {
                if (e.PropertyName.Equals(nameof(sut.Departments)))
                    invoked = true;
            };
            // Act
            sut.Departments = new ObservableCollection<DepartmentDTO>();

            // Assert
            Assert.True(invoked);
        }

        [Fact]
        public async void ListNotEmpty_After_Initializing()
        {
            // Arrange
            var departmentApiMock = Fixture.Freeze<Mock<IDepartmentApi>>();
            var departments = Fixture.CreateMany<DepartmentDTO>().ToList();

            var response = Fixture
                .Build<ResponseListDepartmentDTO>()
                .With(x => x.Success, true)
                .With(r => r.Data, departments)
                .Create();

            departmentApiMock
                .Setup(n => n.V1DepartmentGetAsync())
                .ReturnsAsync(response);

            var sut = Fixture.Create<ChooseDepartmentViewModel>();

            // Act
            await sut.InitializeAsync(null);

            // Assert
            Assert.True(sut.Departments.Count > 0);
        }

        [Fact]
        public async void SendsError_When_ResponseNotSuccessful()
        {
            // Arrange
            var response = Fixture
                .Build<ResponseListDepartmentDTO>()
                .With(x => x.Success, false)
                .Create();

            var departmentApiMock = Fixture
                .Freeze<Mock<IDepartmentApi>>()
                .Setup(n => n.V1DepartmentGetAsync())
                .ReturnsAsync(response);

            var sut = Fixture.Create<ChooseDepartmentViewModel>();

            bool errorWasSent = false;

            // Act
            await sut.InitializeAsync(null);

            // Assert
            Assert.True(errorWasSent);
        }

        [Fact]
        public async void SendsError_When_ResponseThrowsApiException()
        {
            // Arrange
            var sut = Fixture.Create<ChooseDepartmentViewModel>();
            bool errorWasSent = false;

            // Act
            await sut.InitializeAsync(null);

            // Assert
            Assert.True(errorWasSent);
        }
    }
}
