namespace Magaz4._1NaumPir.Models
{
    public enum UserRole { Guest, Client, Manager, Admin }
    public class User
    {
        public string Login { get; set; }
        public string Password { get; set; }
        public string FullName { get; set; }
        public UserRole Role { get; set; }
    }
}