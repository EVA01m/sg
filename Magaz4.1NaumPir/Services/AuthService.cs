using System.Linq;
using Magaz4._1NaumPir.Models;

namespace Magaz4._1NaumPir.Services
{
    public static class AuthService
    {
        public static User Authenticate(string login, string password)
        {
            return DataService.Users.FirstOrDefault(u => u.Login == login && u.Password == password);
        }
    }
}