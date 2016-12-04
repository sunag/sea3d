using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Poonya.Server;
using System.Threading;

namespace SEA3D.Server
{
    class Program
    {
        static void Main(string[] args)
        {
            FileServer FileServ = new FileServer();

            Console.WriteLine("Port: {0}", FileServ.Server.Port);

            Console.ReadLine();
            Console.ReadKey(true);
        }

        public static void WriteKeyPressForExit(ConsoleKey key = ConsoleKey.Enter)
        {
            Console.WriteLine();
            Console.WriteLine("Press the {0} key on your keyboard to exit . . .", key);
            while (Console.ReadKey(intercept: true).Key != key) { }
        }

        public static void Pause()
        {
            Console.WriteLine();
            System.Diagnostics.Process pauseProc =
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo() { FileName = "cmd", Arguments = "/C pause", UseShellExecute = false });
            pauseProc.WaitForExit();
        }
    }
}
