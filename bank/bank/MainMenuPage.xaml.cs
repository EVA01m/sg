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
    /// Логика взаимодействия для MainMenuPage.xaml
    /// </summary>
    public partial class MainMenuPage : Page
    {
        public MainMenuPage()
        {
            InitializeComponent();
        }

        private void ButDM_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new WDPage());
        }

        private void ButWM_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new WDPage());
        }

        private void ButBM_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Возьмите чек из банкомата");
        }

        private void ButRM_Click(object sender, RoutedEventArgs e)
        { 
            NavigationService.GoBack();
        }
    }
}
