/* 
 * The Giraf REST API
 *
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * OpenAPI spec version: v1
 * 
 * Generated by: https://github.com/swagger-api/swagger-codegen.git
 */

using System;
using System.Linq;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.ComponentModel.DataAnnotations;
using SwaggerDateConverter = IO.Swagger.Client.SwaggerDateConverter;

namespace IO.Swagger.Model
{
    /// <summary>
    /// The LauncherOptions, which is the various settings the users can add to customize the Launcher App.
    /// </summary>
    [DataContract]
    public partial class LauncherOptions :  IEquatable<LauncherOptions>, IValidatableObject
    {
        /// <summary>
        /// Preferred orientation of device/screen
        /// </summary>
        /// <value>Preferred orientation of device/screen</value>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum OrientationEnum
        {
            
            /// <summary>
            /// Enum Portrait for value: portrait
            /// </summary>
            [EnumMember(Value = "portrait")]
            Portrait = 1,
            
            /// <summary>
            /// Enum Landscape for value: landscape
            /// </summary>
            [EnumMember(Value = "landscape")]
            Landscape = 2
        }

        /// <summary>
        /// Preferred orientation of device/screen
        /// </summary>
        /// <value>Preferred orientation of device/screen</value>
        [DataMember(Name="orientation", EmitDefaultValue=false)]
        public OrientationEnum Orientation { get; set; }
        /// <summary>
        /// Preferred appearence of checked resources
        /// </summary>
        /// <value>Preferred appearence of checked resources</value>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum CheckResourceAppearenceEnum
        {
            
            /// <summary>
            /// Enum Normal for value: normal
            /// </summary>
            [EnumMember(Value = "normal")]
            Normal = 1,
            
            /// <summary>
            /// Enum Checkmark for value: checkmark
            /// </summary>
            [EnumMember(Value = "checkmark")]
            Checkmark = 2,
            
            /// <summary>
            /// Enum Removed for value: removed
            /// </summary>
            [EnumMember(Value = "removed")]
            Removed = 3,
            
            /// <summary>
            /// Enum MovedToRight for value: movedToRight
            /// </summary>
            [EnumMember(Value = "movedToRight")]
            MovedToRight = 4,
            
            /// <summary>
            /// Enum GreyedOut for value: greyedOut
            /// </summary>
            [EnumMember(Value = "greyedOut")]
            GreyedOut = 5
        }

        /// <summary>
        /// Preferred appearence of checked resources
        /// </summary>
        /// <value>Preferred appearence of checked resources</value>
        [DataMember(Name="checkResourceAppearence", EmitDefaultValue=false)]
        public CheckResourceAppearenceEnum CheckResourceAppearence { get; set; }
        /// <summary>
        /// Preferred appearence of timer
        /// </summary>
        /// <value>Preferred appearence of timer</value>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum DefaultTimerEnum
        {
            
            /// <summary>
            /// Enum Hourglass for value: hourglass
            /// </summary>
            [EnumMember(Value = "hourglass")]
            Hourglass = 1,
            
            /// <summary>
            /// Enum AnalogClock for value: analogClock
            /// </summary>
            [EnumMember(Value = "analogClock")]
            AnalogClock = 2
        }

        /// <summary>
        /// Preferred appearence of timer
        /// </summary>
        /// <value>Preferred appearence of timer</value>
        [DataMember(Name="defaultTimer", EmitDefaultValue=false)]
        public DefaultTimerEnum DefaultTimer { get; set; }
        /// <summary>
        /// The preferred theme
        /// </summary>
        /// <value>The preferred theme</value>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum ThemeEnum
        {
            
            /// <summary>
            /// Enum GirafYellow for value: girafYellow
            /// </summary>
            [EnumMember(Value = "girafYellow")]
            GirafYellow = 1,
            
            /// <summary>
            /// Enum GirafGreen for value: girafGreen
            /// </summary>
            [EnumMember(Value = "girafGreen")]
            GirafGreen = 2,
            
            /// <summary>
            /// Enum Greyscale for value: greyscale
            /// </summary>
            [EnumMember(Value = "greyscale")]
            Greyscale = 3
        }

        /// <summary>
        /// The preferred theme
        /// </summary>
        /// <value>The preferred theme</value>
        [DataMember(Name="theme", EmitDefaultValue=false)]
        public ThemeEnum Theme { get; set; }
        /// <summary>
        /// Initializes a new instance of the <see cref="LauncherOptions" /> class.
        /// </summary>
        [JsonConstructorAttribute]
        protected LauncherOptions() { }
        /// <summary>
        /// Initializes a new instance of the <see cref="LauncherOptions" /> class.
        /// </summary>
        /// <param name="DisplayLauncherAnimations">A flag indicating whether to run applications in grayscale or not..</param>
        /// <param name="AppGridSizeRows">A field for storing how many rows to display in the GirafLauncher application..</param>
        /// <param name="AppGridSizeColumns">A field for storing how many columns to display in the GirafLauncher application..</param>
        /// <param name="Orientation">Preferred orientation of device/screen (required).</param>
        /// <param name="CheckResourceAppearence">Preferred appearence of checked resources (required).</param>
        /// <param name="DefaultTimer">Preferred appearence of timer (required).</param>
        /// <param name="TimerSeconds">Number of seconds for timer.</param>
        /// <param name="ActivitiesCount">Number of activities.</param>
        /// <param name="Theme">The preferred theme (required).</param>
        public LauncherOptions(bool? DisplayLauncherAnimations = default(bool?), int? AppGridSizeRows = default(int?), int? AppGridSizeColumns = default(int?), OrientationEnum Orientation = default(OrientationEnum), CheckResourceAppearenceEnum CheckResourceAppearence = default(CheckResourceAppearenceEnum), DefaultTimerEnum DefaultTimer = default(DefaultTimerEnum), int? TimerSeconds = default(int?), int? ActivitiesCount = default(int?), ThemeEnum Theme = default(ThemeEnum))
        {
            // to ensure "Orientation" is required (not null)
            if (Orientation == null)
            {
                throw new InvalidDataException("Orientation is a required property for LauncherOptions and cannot be null");
            }
            else
            {
                this.Orientation = Orientation;
            }
            // to ensure "CheckResourceAppearence" is required (not null)
            if (CheckResourceAppearence == null)
            {
                throw new InvalidDataException("CheckResourceAppearence is a required property for LauncherOptions and cannot be null");
            }
            else
            {
                this.CheckResourceAppearence = CheckResourceAppearence;
            }
            // to ensure "DefaultTimer" is required (not null)
            if (DefaultTimer == null)
            {
                throw new InvalidDataException("DefaultTimer is a required property for LauncherOptions and cannot be null");
            }
            else
            {
                this.DefaultTimer = DefaultTimer;
            }
            // to ensure "Theme" is required (not null)
            if (Theme == null)
            {
                throw new InvalidDataException("Theme is a required property for LauncherOptions and cannot be null");
            }
            else
            {
                this.Theme = Theme;
            }
            this.DisplayLauncherAnimations = DisplayLauncherAnimations;
            this.AppGridSizeRows = AppGridSizeRows;
            this.AppGridSizeColumns = AppGridSizeColumns;
            this.TimerSeconds = TimerSeconds;
            this.ActivitiesCount = ActivitiesCount;
        }
        
        /// <summary>
        /// Key for LauncherOptions
        /// </summary>
        /// <value>Key for LauncherOptions</value>
        [DataMember(Name="key", EmitDefaultValue=false)]
        public long? Key { get; private set; }

        /// <summary>
        /// A flag indicating whether to run applications in grayscale or not.
        /// </summary>
        /// <value>A flag indicating whether to run applications in grayscale or not.</value>
        [DataMember(Name="displayLauncherAnimations", EmitDefaultValue=false)]
        public bool? DisplayLauncherAnimations { get; set; }

        /// <summary>
        /// A field for storing how many rows to display in the GirafLauncher application.
        /// </summary>
        /// <value>A field for storing how many rows to display in the GirafLauncher application.</value>
        [DataMember(Name="appGridSizeRows", EmitDefaultValue=false)]
        public int? AppGridSizeRows { get; set; }

        /// <summary>
        /// A field for storing how many columns to display in the GirafLauncher application.
        /// </summary>
        /// <value>A field for storing how many columns to display in the GirafLauncher application.</value>
        [DataMember(Name="appGridSizeColumns", EmitDefaultValue=false)]
        public int? AppGridSizeColumns { get; set; }




        /// <summary>
        /// Number of seconds for timer
        /// </summary>
        /// <value>Number of seconds for timer</value>
        [DataMember(Name="timerSeconds", EmitDefaultValue=false)]
        public int? TimerSeconds { get; set; }

        /// <summary>
        /// Number of activities
        /// </summary>
        /// <value>Number of activities</value>
        [DataMember(Name="activitiesCount", EmitDefaultValue=false)]
        public int? ActivitiesCount { get; set; }


        /// <summary>
        /// Returns the string presentation of the object
        /// </summary>
        /// <returns>String presentation of the object</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append("class LauncherOptions {\n");
            sb.Append("  Key: ").Append(Key).Append("\n");
            sb.Append("  DisplayLauncherAnimations: ").Append(DisplayLauncherAnimations).Append("\n");
            sb.Append("  AppGridSizeRows: ").Append(AppGridSizeRows).Append("\n");
            sb.Append("  AppGridSizeColumns: ").Append(AppGridSizeColumns).Append("\n");
            sb.Append("  Orientation: ").Append(Orientation).Append("\n");
            sb.Append("  CheckResourceAppearence: ").Append(CheckResourceAppearence).Append("\n");
            sb.Append("  DefaultTimer: ").Append(DefaultTimer).Append("\n");
            sb.Append("  TimerSeconds: ").Append(TimerSeconds).Append("\n");
            sb.Append("  ActivitiesCount: ").Append(ActivitiesCount).Append("\n");
            sb.Append("  Theme: ").Append(Theme).Append("\n");
            sb.Append("}\n");
            return sb.ToString();
        }
  
        /// <summary>
        /// Returns the JSON string presentation of the object
        /// </summary>
        /// <returns>JSON string presentation of the object</returns>
        public string ToJson()
        {
            return JsonConvert.SerializeObject(this, Formatting.Indented);
        }

        /// <summary>
        /// Returns true if objects are equal
        /// </summary>
        /// <param name="input">Object to be compared</param>
        /// <returns>Boolean</returns>
        public override bool Equals(object input)
        {
            return this.Equals(input as LauncherOptions);
        }

        /// <summary>
        /// Returns true if LauncherOptions instances are equal
        /// </summary>
        /// <param name="input">Instance of LauncherOptions to be compared</param>
        /// <returns>Boolean</returns>
        public bool Equals(LauncherOptions input)
        {
            if (input == null)
                return false;

            return 
                (
                    this.Key == input.Key ||
                    (this.Key != null &&
                    this.Key.Equals(input.Key))
                ) && 
                (
                    this.DisplayLauncherAnimations == input.DisplayLauncherAnimations ||
                    (this.DisplayLauncherAnimations != null &&
                    this.DisplayLauncherAnimations.Equals(input.DisplayLauncherAnimations))
                ) && 
                (
                    this.AppGridSizeRows == input.AppGridSizeRows ||
                    (this.AppGridSizeRows != null &&
                    this.AppGridSizeRows.Equals(input.AppGridSizeRows))
                ) && 
                (
                    this.AppGridSizeColumns == input.AppGridSizeColumns ||
                    (this.AppGridSizeColumns != null &&
                    this.AppGridSizeColumns.Equals(input.AppGridSizeColumns))
                ) && 
                (
                    this.Orientation == input.Orientation ||
                    (this.Orientation != null &&
                    this.Orientation.Equals(input.Orientation))
                ) && 
                (
                    this.CheckResourceAppearence == input.CheckResourceAppearence ||
                    (this.CheckResourceAppearence != null &&
                    this.CheckResourceAppearence.Equals(input.CheckResourceAppearence))
                ) && 
                (
                    this.DefaultTimer == input.DefaultTimer ||
                    (this.DefaultTimer != null &&
                    this.DefaultTimer.Equals(input.DefaultTimer))
                ) && 
                (
                    this.TimerSeconds == input.TimerSeconds ||
                    (this.TimerSeconds != null &&
                    this.TimerSeconds.Equals(input.TimerSeconds))
                ) && 
                (
                    this.ActivitiesCount == input.ActivitiesCount ||
                    (this.ActivitiesCount != null &&
                    this.ActivitiesCount.Equals(input.ActivitiesCount))
                ) && 
                (
                    this.Theme == input.Theme ||
                    (this.Theme != null &&
                    this.Theme.Equals(input.Theme))
                );
        }

        /// <summary>
        /// Gets the hash code
        /// </summary>
        /// <returns>Hash code</returns>
        public override int GetHashCode()
        {
            unchecked // Overflow is fine, just wrap
            {
                int hashCode = 41;
                if (this.Key != null)
                    hashCode = hashCode * 59 + this.Key.GetHashCode();
                if (this.DisplayLauncherAnimations != null)
                    hashCode = hashCode * 59 + this.DisplayLauncherAnimations.GetHashCode();
                if (this.AppGridSizeRows != null)
                    hashCode = hashCode * 59 + this.AppGridSizeRows.GetHashCode();
                if (this.AppGridSizeColumns != null)
                    hashCode = hashCode * 59 + this.AppGridSizeColumns.GetHashCode();
                if (this.Orientation != null)
                    hashCode = hashCode * 59 + this.Orientation.GetHashCode();
                if (this.CheckResourceAppearence != null)
                    hashCode = hashCode * 59 + this.CheckResourceAppearence.GetHashCode();
                if (this.DefaultTimer != null)
                    hashCode = hashCode * 59 + this.DefaultTimer.GetHashCode();
                if (this.TimerSeconds != null)
                    hashCode = hashCode * 59 + this.TimerSeconds.GetHashCode();
                if (this.ActivitiesCount != null)
                    hashCode = hashCode * 59 + this.ActivitiesCount.GetHashCode();
                if (this.Theme != null)
                    hashCode = hashCode * 59 + this.Theme.GetHashCode();
                return hashCode;
            }
        }

        /// <summary>
        /// To validate all properties of the instance
        /// </summary>
        /// <param name="validationContext">Validation context</param>
        /// <returns>Validation Result</returns>
        IEnumerable<System.ComponentModel.DataAnnotations.ValidationResult> IValidatableObject.Validate(ValidationContext validationContext)
        {
            yield break;
        }
    }

}
