using System.Collections.ObjectModel;
using Magaz4._1NaumPir.Models;

namespace Magaz4._1NaumPir.Services
{
    public static class DataService
    {
        public static ObservableCollection<User> Users { get; private set; }
        public static ObservableCollection<Product> Products { get; private set; }

        static DataService()
        {
            Users = new ObservableCollection<User>
            {
                new User { Login = "client", Password = "1", FullName = "Иванов Иван Иванович", Role = UserRole.Client },
                new User { Login = "manager", Password = "1", FullName = "Петрова Анна Сергеевна", Role = UserRole.Manager },
                new User { Login = "admin", Password = "1", FullName = "Сидоров Дмитрий Алексеевич", Role = UserRole.Admin }
            };
            Products = new ObservableCollection<Product>
            {
                new Product { Id = 1, Name = "Кольцо с бриллиантом", Description = "Золото 585, бриллиант 0.5 кар", Manufacturer = "De Beers", Price = 75000, DiscountPercent = 0 },
                new Product { Id = 2, Name = "Серьги с изумрудом", Description = "Серебро, изумруд 2ct", Manufacturer = "Emerald Co", Price = 25000, DiscountPercent = 20 },
                new Product { Id = 3, Name = "Подвеска с сапфиром", Description = "Белое золото, сапфир", Manufacturer = "Sapphire Ltd", Price = 43000, DiscountPercent = 10 },
                new Product { Id = 4, Name = "Браслет с фианитами", Description = "Позолота, фианиты", Manufacturer = "Fianit Style", Price = 8900, DiscountPercent = 5 },
                new Product { Id = 5, Name = "Бриллиант 1 карат", Description = "Круглая огранка", Manufacturer = "Diamond Trust", Price = 120000, DiscountPercent = 18, Buy = "Купит"}
            };
        }
    }
}