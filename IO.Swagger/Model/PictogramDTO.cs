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
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.ComponentModel.DataAnnotations;

namespace IO.Swagger.Model
{
    /// <summary>
    /// Defines the structure of Pictogram when serializing and deserializing data. Data transfer objects (DTOs)   were introduced in the project due to problems with circular references in the model classes.
    /// </summary>
    [DataContract]
    public partial class PictogramDTO :  IEquatable<PictogramDTO>, IValidatableObject
    {
        /// <summary>
        /// Defines AccessLevel
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum AccessLevelEnum
        {
            
            /// <summary>
            /// Enum PUBLIC for value: PUBLIC
            /// </summary>
            [EnumMember(Value = "PUBLIC")]
            PUBLIC = 1,
            
            /// <summary>
            /// Enum PROTECTED for value: PROTECTED
            /// </summary>
            [EnumMember(Value = "PROTECTED")]
            PROTECTED = 2,
            
            /// <summary>
            /// Enum PRIVATE for value: PRIVATE
            /// </summary>
            [EnumMember(Value = "PRIVATE")]
            PRIVATE = 3
        }

        /// <summary>
        /// Gets or Sets AccessLevel
        /// </summary>
        [DataMember(Name="accessLevel", EmitDefaultValue=false)]
        public AccessLevelEnum AccessLevel { get; set; }
        /// <summary>
        /// Initializes a new instance of the <see cref="PictogramDTO" /> class.
        /// </summary>
        [JsonConstructorAttribute]
        protected PictogramDTO() { }
        /// <summary>
        /// Initializes a new instance of the <see cref="PictogramDTO" /> class.
        /// </summary>
        /// <param name="AccessLevel">AccessLevel (required).</param>
        /// <param name="Title">Title (required).</param>
        /// <param name="Id">The id of the resource..</param>
        /// <param name="LastEdit">The last time the resource was edited..</param>
        public PictogramDTO(AccessLevelEnum AccessLevel = default(AccessLevelEnum), string Title = default(string), long? Id = default(long?), DateTime? LastEdit = default(DateTime?))
        {
            // to ensure "AccessLevel" is required (not null)
            if (AccessLevel == null)
            {
                throw new InvalidDataException("AccessLevel is a required property for PictogramDTO and cannot be null");
            }
            else
            {
                this.AccessLevel = AccessLevel;
            }
            // to ensure "Title" is required (not null)
            if (Title == null)
            {
                throw new InvalidDataException("Title is a required property for PictogramDTO and cannot be null");
            }
            else
            {
                this.Title = Title;
            }
            this.Id = Id;
            this.LastEdit = LastEdit;
        }
        

        /// <summary>
        /// Gets or Sets ImageUrl
        /// </summary>
        [DataMember(Name="imageUrl", EmitDefaultValue=false)]
        public string ImageUrl { get; private set; }

        /// <summary>
        /// Gets or Sets ImageHash
        /// </summary>
        [DataMember(Name="imageHash", EmitDefaultValue=false)]
        public string ImageHash { get; private set; }

        /// <summary>
        /// Gets or Sets Title
        /// </summary>
        [DataMember(Name="title", EmitDefaultValue=false)]
        public string Title { get; set; }

        /// <summary>
        /// The id of the resource.
        /// </summary>
        /// <value>The id of the resource.</value>
        [DataMember(Name="id", EmitDefaultValue=false)]
        public long? Id { get; set; }

        /// <summary>
        /// The last time the resource was edited.
        /// </summary>
        /// <value>The last time the resource was edited.</value>
        [DataMember(Name="lastEdit", EmitDefaultValue=false)]
        public DateTime? LastEdit { get; set; }

        /// <summary>
        /// Returns the string presentation of the object
        /// </summary>
        /// <returns>String presentation of the object</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append("class PictogramDTO {\n");
            sb.Append("  AccessLevel: ").Append(AccessLevel).Append("\n");
            sb.Append("  ImageUrl: ").Append(ImageUrl).Append("\n");
            sb.Append("  ImageHash: ").Append(ImageHash).Append("\n");
            sb.Append("  Title: ").Append(Title).Append("\n");
            sb.Append("  Id: ").Append(Id).Append("\n");
            sb.Append("  LastEdit: ").Append(LastEdit).Append("\n");
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
            return this.Equals(input as PictogramDTO);
        }

        /// <summary>
        /// Returns true if PictogramDTO instances are equal
        /// </summary>
        /// <param name="input">Instance of PictogramDTO to be compared</param>
        /// <returns>Boolean</returns>
        public bool Equals(PictogramDTO input)
        {
            if (input == null)
                return false;

            return 
                (
                    this.AccessLevel == input.AccessLevel ||
                    (this.AccessLevel != null &&
                    this.AccessLevel.Equals(input.AccessLevel))
                ) && 
                (
                    this.ImageUrl == input.ImageUrl ||
                    (this.ImageUrl != null &&
                    this.ImageUrl.Equals(input.ImageUrl))
                ) && 
                (
                    this.ImageHash == input.ImageHash ||
                    (this.ImageHash != null &&
                    this.ImageHash.Equals(input.ImageHash))
                ) && 
                (
                    this.Title == input.Title ||
                    (this.Title != null &&
                    this.Title.Equals(input.Title))
                ) && 
                (
                    this.Id == input.Id ||
                    (this.Id != null &&
                    this.Id.Equals(input.Id))
                ) && 
                (
                    this.LastEdit == input.LastEdit ||
                    (this.LastEdit != null &&
                    this.LastEdit.Equals(input.LastEdit))
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
                if (this.AccessLevel != null)
                    hashCode = hashCode * 59 + this.AccessLevel.GetHashCode();
                if (this.ImageUrl != null)
                    hashCode = hashCode * 59 + this.ImageUrl.GetHashCode();
                if (this.ImageHash != null)
                    hashCode = hashCode * 59 + this.ImageHash.GetHashCode();
                if (this.Title != null)
                    hashCode = hashCode * 59 + this.Title.GetHashCode();
                if (this.Id != null)
                    hashCode = hashCode * 59 + this.Id.GetHashCode();
                if (this.LastEdit != null)
                    hashCode = hashCode * 59 + this.LastEdit.GetHashCode();
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
