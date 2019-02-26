using RGiesecke.DllExport;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace A3ExtendedChat
{
    public class DllEntry
    {
        #region Misc RVExtension Requirements
#if IS_x64
        [DllExport("RVExtensionVersion", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtensionVersion@8", CallingConvention = CallingConvention.Winapi)]
#endif
        public static void RvExtensionVersion(StringBuilder output, int outputSize)
        {
            outputSize--;
            output.Append("1.0.0");
        }

#if IS_x64
        [DllExport("RVExtension", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtension@12", CallingConvention = CallingConvention.Winapi)]
#endif
        public static void RvExtension(StringBuilder output, int outputSize,
            [MarshalAs(UnmanagedType.LPStr)] string function)
        {
            outputSize--;
            output.Append(function);
        }

#if IS_x64
        [DllExport("RVExtensionArgs", CallingConvention = CallingConvention.Winapi)]
#else
        [DllExport("_RVExtensionArgs@20", CallingConvention = CallingConvention.Winapi)]
#endif
        #endregion
        public static int RvExtensionArgs(StringBuilder output, int outputSize,
            [MarshalAs(UnmanagedType.LPStr)] string function,
            [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr, SizeParamIndex = 4)] string[] args, int argCount)
        {
            outputSize--;
            try
            {
                if (args.Length > 0) Log(function, args[0]);
            }
            catch (Exception e)
            {
                Log("extension", $"{e}");
            };
            return 1;
        }

        private static readonly string AssemblyPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        private static readonly string ExtFilePath = Path.Combine(AssemblyPath, "logs");
        private static readonly string LogsFilePath = Path.Combine(ExtFilePath, $"{DateTime.Now.ToString("yyyy-MM-dd.HH-mm-ss")}");
        private static void Log(string type, string log)
        {
            if (!Directory.Exists(LogsFilePath)) Directory.CreateDirectory(LogsFilePath);
            string file = Path.Combine(LogsFilePath, $"{string.Join("_", type.Split(Path.GetInvalidFileNameChars()))}.log");
            string line = $"{DateTime.Now.ToString("T")} - {log}";

            List<string> lines;
            if (File.Exists(file))
                lines = new List<string>(File.ReadAllLines(file));
            else
                lines = new List<string>() { };

            lines.Add(line);
            File.WriteAllLines(file, lines);
        }
    }
}