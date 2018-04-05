/* 
 * My API
 *
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * OpenAPI spec version: v1
 * 
 * Generated by: https://github.com/swagger-api/swagger-codegen.git
 */

using System;
using System.IO;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reflection;
using RestSharp;
using NUnit.Framework;

using IO.Swagger.Client;
using IO.Swagger.Api;
using IO.Swagger.Model;

namespace IO.Swagger.Test
{
    /// <summary>
    ///  Class for testing AccountApi
    /// </summary>
    /// <remarks>
    /// This file is automatically generated by Swagger Codegen.
    /// Please update the test case below to test the API endpoint.
    /// </remarks>
    [TestFixture]
    public class AccountApiTests
    {
        private AccountApi instance;

        /// <summary>
        /// Setup before each unit test
        /// </summary>
        [SetUp]
        public void Init()
        {
            instance = new AccountApi();
        }

        /// <summary>
        /// Clean up after each unit test
        /// </summary>
        [TearDown]
        public void Cleanup()
        {

        }

        /// <summary>
        /// Test an instance of AccountApi
        /// </summary>
        [Test]
        public void InstanceTest()
        {
            // TODO uncomment below to test 'IsInstanceOfType' AccountApi
            //Assert.IsInstanceOfType(typeof(AccountApi), instance, "instance is a AccountApi");
        }

        
        /// <summary>
        /// Test V1AccountAccessDeniedGet
        /// </summary>
        [Test]
        public void V1AccountAccessDeniedGetTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //instance.V1AccountAccessDeniedGet();
            
        }
        
        /// <summary>
        /// Test V1AccountChangePasswordPost
        /// </summary>
        [Test]
        public void V1AccountChangePasswordPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //string oldPassword = null;
            //string newPassword = null;
            //var response = instance.V1AccountChangePasswordPost(oldPassword, newPassword);
            //Assert.IsInstanceOf<Response> (response, "response is Response");
        }
        
        /// <summary>
        /// Test V1AccountForgotPasswordPost
        /// </summary>
        [Test]
        public void V1AccountForgotPasswordPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //ForgotPasswordDTO model = null;
            //var response = instance.V1AccountForgotPasswordPost(model);
            //Assert.IsInstanceOf<Response> (response, "response is Response");
        }
        
        /// <summary>
        /// Test V1AccountLoginPost
        /// </summary>
        [Test]
        public void V1AccountLoginPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //LoginDTO model = null;
            //var response = instance.V1AccountLoginPost(model);
            //Assert.IsInstanceOf<ResponseString> (response, "response is ResponseString");
        }
        
        /// <summary>
        /// Test V1AccountLogoutPost
        /// </summary>
        [Test]
        public void V1AccountLogoutPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //var response = instance.V1AccountLogoutPost();
            //Assert.IsInstanceOf<Response> (response, "response is Response");
        }
        
        /// <summary>
        /// Test V1AccountRegisterPost
        /// </summary>
        [Test]
        public void V1AccountRegisterPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //RegisterDTO model = null;
            //var response = instance.V1AccountRegisterPost(model);
            //Assert.IsInstanceOf<ResponseGirafUserDTO> (response, "response is ResponseGirafUserDTO");
        }
        
        /// <summary>
        /// Test V1AccountResetPasswordConfirmationGet
        /// </summary>
        [Test]
        public void V1AccountResetPasswordConfirmationGetTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //instance.V1AccountResetPasswordConfirmationGet();
            
        }
        
        /// <summary>
        /// Test V1AccountResetPasswordGet
        /// </summary>
        [Test]
        public void V1AccountResetPasswordGetTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //string code = null;
            //instance.V1AccountResetPasswordGet(code);
            
        }
        
        /// <summary>
        /// Test V1AccountResetPasswordPost
        /// </summary>
        [Test]
        public void V1AccountResetPasswordPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //string username = null;
            //string password = null;
            //string confirmPassword = null;
            //string code = null;
            //instance.V1AccountResetPasswordPost(username, password, confirmPassword, code);
            
        }
        
        /// <summary>
        /// Test V1AccountSetPasswordPost
        /// </summary>
        [Test]
        public void V1AccountSetPasswordPostTest()
        {
            // TODO uncomment below to test the method and replace null with proper value
            //string newPassword = null;
            //string confirmPassword = null;
            //var response = instance.V1AccountSetPasswordPost(newPassword, confirmPassword);
            //Assert.IsInstanceOf<Response> (response, "response is Response");
        }
        
    }

}
