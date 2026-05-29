using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Data;
using Magaz4._1NaumPir.Models;
using Magaz4._1NaumPir.Services;

namespace Magaz4._1NaumPir
{
    public partial class MainWindow : Window
    {
        private User user;
        private ObservableCollection<Product> products = new ObservableCollection<Product>();

        public MainWindow(User u)
        {
            InitializeComponent();
            user = u;
            UserInfo.Text = user == null ? "Гость" : $"{user.FullName} ({user.Role})";
            UpdateProducts("");
        }

        private void SearchBox_TextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
        {
            UpdateProducts(SearchBox.Text);
        }

        private void UpdateProducts(string search)
        {
            products.Clear();
            var query = DataService.Products.Where(p => string.IsNullOrEmpty(search) || p.Name.ToLower().Contains(search.ToLower()));
            foreach (var p in query) products.Add(p);
            ProductsList.ItemsSource = products;
        }

        private void Logout_Click(object sender, RoutedEventArgs e)
        {
            new LoginWindow().Show();
            this.Close();
        }
    }

    public class DiscountVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            decimal disc = (decimal)value;
            return disc > 0 ? Visibility.Visible : Visibility.Collapsed;
        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}