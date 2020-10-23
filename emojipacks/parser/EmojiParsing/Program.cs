using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;
using Newtonsoft.Json.Linq;
using System.Drawing;
using System.Drawing.Imaging;

namespace EmojiParsing
{
    class Program
    {
        static void Main(string[] args)
        {
			// Emoji data source
			// https://www.jsdelivr.com/package/npm/emoji-datasource-twitter

			string pathRoot = @"D:\__git\Personal\A3ExtendedChat\A3ExtendedChat\emojipacks";
			string pathTwitter = Path.Combine(pathRoot,"twitter");
			string infoFilePath = Path.Combine(pathTwitter, "emoji.json");
			string imageFolderPath = Path.Combine(pathTwitter, @"img\twitter\64");
			string outputFolderPath = Path.Combine(pathRoot, "output");

			if (Directory.Exists(outputFolderPath)) Directory.Delete(outputFolderPath,true);
			Directory.CreateDirectory(outputFolderPath);

			string emojiInfoS = File.ReadAllText(infoFilePath);
			JArray emojiInfo = JArray.Parse(emojiInfoS);

			Dictionary<string,List<string>> categories = new Dictionary<string, List<string>>();

			TextInfo textInfo = CultureInfo.CurrentCulture.TextInfo;

			foreach (JObject e in emojiInfo)
			{
				JToken hasTwitterImg = e["has_img_twitter"];
				if (hasTwitterImg != null && (bool)hasTwitterImg == true)
				{
					string category = e["category"].ToString();
					string categoryPath = Path.Combine(outputFolderPath, CleanKey(category).ToLower());

					if (!Directory.Exists(categoryPath))
					{
						Directory.CreateDirectory(categoryPath);
						Directory.CreateDirectory(Path.Combine(categoryPath,"data"));
					}

					string dest = Path.Combine(categoryPath, $"data\\{e["short_name"]}{Path.GetExtension(e["image"].ToString())}");

					if (!File.Exists(dest))
					{
						string source = Path.Combine(imageFolderPath, e["image"].ToString());

						Console.WriteLine($"{e["image"]} -> {Path.GetFileName(dest)}");

						/*
						 * ImageToPAA requires .png be 32bit color depth
						 * Some icons are 8bit by default
						 * The ideal solution is to only convert images that are not already 32bit,
						 * but I dont know how to check that so I'm converting them all.
						 * */
						// https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoder.colordepth?view=dotnet-plat-ext-3.1
						Image icon = Image.FromFile(source);
						ImageCodecInfo imageCodecInfo = GetEncoderInfo("image/png");
						Encoder encoder = Encoder.ColorDepth;
						EncoderParameters encoderParameters = new EncoderParameters(1);
						EncoderParameter encoderParameter = new EncoderParameter(encoder, 32L);
						encoderParameters.Param[0] = encoderParameter;
						icon.Save(dest, imageCodecInfo, encoderParameters);

						//File.Copy(source, dest);

						string name = textInfo.ToTitleCase(e["name"].ToString().ToLower());
						if (name == "")
							name = textInfo.ToTitleCase(e["short_name"].ToString().ToLower().Replace('_',' '));

						List<string> keywords = new List<string>();
						if (e["short_names"] != null)
							foreach (string s in e["short_names"])
								keywords.Add($"\"{s}\"");

						List<string> shortcuts = new List<string>();
						if (e["texts"] != null)
							foreach (string s in e["texts"])
								shortcuts.Add($"\"{s}\"");

						File.WriteAllLines(Path.Combine(categoryPath, $"data\\{e["short_name"]}.cpp"), new List<string>() {
							$"class {e["short_name"]} {{",
							$"{(char)9}displayName=\"{name}\";",
							$"{(char)9}icon=\"cau\\extendedchat\\emojipack\\twemoji\\{CleanKey(category).ToLower()}\\data\\{e["short_name"]}.paa\";",
							$"{(char)9}keywords[]={{{string.Join(",", keywords)}}};",
							$"{(char)9}shortcuts[]={{{string.Join(",", shortcuts)}}};",
							$"{(char)9}condition=\"true\";",
							"};"
						});

						if (!categories.ContainsKey(category)) categories.Add(category, new List<string>());
						categories[category].Add($"{(char)9}#include \"data\\{e["short_name"]}.cpp\"");
					}
				}
			}

			foreach (string k in categories.Keys)
			{
				categories[k].Sort();
				string kSafe = CleanKey(k);

				File.WriteAllLines(Path.Combine(outputFolderPath, $"{kSafe}\\config.cpp"), new List<string>()
				{
					"class CfgPatches {",
					$"{(char)9}class CAU_ExtendedChat_EmojiPack_Twemoji_{kSafe} {{",
					$"{(char)9}{(char)9}name=\"CAU_ExtendedChat_EmojiPack_Twemoji_{kSafe}\";",
					$"{(char)9}{(char)9}author=\"ConnorAU\";",
					$"{(char)9}{(char)9}url=\"https://github.com/ConnorAU/A3ExtendedChat\";",
					"",
					$"{(char)9}{(char)9}requiredVersion=0.01;",
					$"{(char)9}{(char)9}requiredAddons[]={{}};",
					$"{(char)9}{(char)9}units[]={{}};",
					$"{(char)9}{(char)9}weapons[]={{}};",
					$"{(char)9}}};",
					"};",
					"",
					"class CfgEmojis {",
					string.Join("\n",categories[k]),
					"};"
				});
				File.WriteAllText(Path.Combine(outputFolderPath, $"{kSafe}\\$PBOPREFIX$"), $"cau\\extendedchat\\emojipack\\twemoji\\{kSafe.ToLower()}");
			}


			Console.WriteLine("done");
			Console.ReadKey();
        }

		private static string CleanKey(string k) => k.Replace(' ', '_').Replace("&", "and");

		// https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoder.colordepth?view=dotnet-plat-ext-3.1
		private static ImageCodecInfo GetEncoderInfo(String mimeType)
		{
			int j;
			ImageCodecInfo[] encoders;
			encoders = ImageCodecInfo.GetImageEncoders();
			for (j = 0; j < encoders.Length; ++j)
			{
				if (encoders[j].MimeType == mimeType)
					return encoders[j];
			}
			return null;
		}
	}
}
