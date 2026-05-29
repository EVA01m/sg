using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace bank
{
    /// <summary>
    /// Логика взаимодействия для PinPage.xaml
    /// </summary>
    public partial class PinPage : Page
    {
        public PinPage()
        {
            InitializeComponent();
        }

        private void ButAP_Click(object sender, RoutedEventArgs e)
        {
            if (pinBox.Password.Length >= 4)
                NavigationService.Navigate(new MainMenuPage());
            else
                MessageBox.Show("Введите 4 цифры");
        }

        private void ButCP_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }
    }
}
