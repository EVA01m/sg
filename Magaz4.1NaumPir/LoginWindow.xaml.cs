using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using System.Windows.Threading;
using Magaz4._1NaumPir.Models;
using Magaz4._1NaumPir.Services;

namespace Magaz4._1NaumPir
{
    public partial class LoginWindow : Window
    {
        private int failCount = 0;
        private bool isBlocked = false;
        private DispatcherTimer timer;
        private string captchaText = "";
        private Random rnd = new Random();

        public LoginWindow() => InitializeComponent();

        private void LoginBtn_Click(object sender, RoutedEventArgs e)
        {
            if (isBlocked) { ErrorMsg.Text = "Блокировка 10 сек"; return; }
            if (failCount >= 1 && !CheckCaptcha()) return;
            var user = AuthService.Authenticate(LoginBox.Text, PasswordBox.Password);
            if (user != null)
            {
                new MainWindow(user).Show();
                this.Close();
            }
            else
            {
                failCount++;
                ErrorMsg.Text = "Неверный логин/пароль";
                if (failCount == 1) ShowCaptcha();
                if (failCount >= 2) Block(10);
            }
        }

        private void GuestBtn_Click(object sender, RoutedEventArgs e)
        {
            if (isBlocked) { ErrorMsg.Text = "Блокировка"; return; }
            new MainWindow(null).Show();
            this.Close();
        }

        private void ShowCaptcha()
        {
            CaptchaPanel.Visibility = Visibility.Visible;
            GenerateCaptcha();
        }

        private void GenerateCaptcha()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            captchaText = new string(Enumerable.Repeat(chars, 4).Select(s => s[rnd.Next(s.Length)]).ToArray());
            CaptchaCanvas.Children.Clear();
            double w = 250, h = 100;

            for (int i = 0; i < 60; i++)
            {
                var dot = new Ellipse { Width = 2, Height = 2, Fill = Brushes.Gray };
                Canvas.SetLeft(dot, rnd.Next(0, (int)w));
                Canvas.SetTop(dot, rnd.Next(0, (int)h));
                CaptchaCanvas.Children.Add(dot);
            }

            for (int i = 0; i < 10; i++)
            {
                var line = new Line
                {
                    X1 = rnd.Next(0, (int)w),
                    Y1 = rnd.Next(0, (int)h),
                    X2 = rnd.Next(0, (int)w),
                    Y2 = rnd.Next(0, (int)h),
                    Stroke = Brushes.LightGray,
                    StrokeThickness = 1
                };
                CaptchaCanvas.Children.Add(line);
            }

            double startX = 20, step = (w - 40) / 4;
            for (int i = 0; i < 4; i++)
            {
                var tb = new TextBlock
                {
                    Text = captchaText[i].ToString(),
                    FontSize = rnd.Next(22, 32),
                    FontWeight = FontWeights.Bold,
                    Foreground = new SolidColorBrush(Color.FromRgb(
                        (byte)rnd.Next(0, 150),
                        (byte)rnd.Next(0, 150),
                        (byte)rnd.Next(0, 150)))
                };

                double x = startX + i * step + rnd.Next(-8, 8);
                double y = rnd.Next(20, 70);
                tb.RenderTransform = new RotateTransform(rnd.Next(-25, 25));
                Canvas.SetLeft(tb, x);
                Canvas.SetTop(tb, y);
                CaptchaCanvas.Children.Add(tb);

                var line = new Line
                {
                    X1 = x - 3,
                    Y1 = y + 8,
                    X2 = x + 22,
                    Y2 = y - 6,
                    Stroke = Brushes.Red,
                    StrokeThickness = 1.5
                };
                CaptchaCanvas.Children.Add(line);
            }
        }

        private bool CheckCaptcha()
        {
            if (CaptchaInput.Text.Trim().Equals(captchaText, StringComparison.OrdinalIgnoreCase))
                return true;
            CaptchaError.Text = "Неверный код";
            GenerateCaptcha();
            CaptchaInput.Text = "";
            return false;
        }

        private void Block(int sec)
        {
            isBlocked = true;
            LoginBtn.IsEnabled = false;
            GuestBtn.IsEnabled = false;
            int rem = sec;
            timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            timer.Tick += (s, e) =>
            {
                if (--rem <= 0)
                {
                    timer.Stop();
                    isBlocked = false;
                    LoginBtn.IsEnabled = GuestBtn.IsEnabled = true;
                    failCount = 0;
                    CaptchaPanel.Visibility = Visibility.Collapsed;
                    ErrorMsg.Text = "";
                    BlockMsg.Text = "";
                }
                else BlockMsg.Text = $"Блокировка {rem} сек";
            };
            timer.Start();
        }
    }
}