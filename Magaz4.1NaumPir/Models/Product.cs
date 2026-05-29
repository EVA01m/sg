using System.ComponentModel;
using System.Windows;

namespace Magaz4._1NaumPir.Models
{
    public class Product : INotifyPropertyChanged
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Buy { get; set; }
        public string Description { get; set; }
        public string Manufacturer { get; set; }
        private decimal price;
        public decimal Price { get => price; set { price = value; OnPropertyChanged("Price"); OnPropertyChanged("FinalPrice"); OnPropertyChanged("PriceDecorations"); } }
        private decimal discountPercent;
        public decimal DiscountPercent { get => discountPercent; set { discountPercent = value; OnPropertyChanged("DiscountPercent"); OnPropertyChanged("FinalPrice"); OnPropertyChanged("PriceDecorations"); } }
        public string ImagePath { get; set; } = "Resources/netk.jpg";
        public decimal FinalPrice => Price * (1 - DiscountPercent / 100);
        public TextDecorationCollection PriceDecorations => DiscountPercent > 0 ? TextDecorations.Strikethrough : null;

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string name) => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}