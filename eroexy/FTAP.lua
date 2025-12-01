local Window = Rayfield:CreateWindow({
   Name = "Fling things and people",
   Icon = 0,
   LoadingTitle = "Fling things and people",
   LoadingSubtitle = "",
   ShowText = "nil",
   Theme = "Default",

   ToggleUIKeybind = "M",

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = true,
      FileName = "eroexyFTAP"
   },

   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "",
      Subtitle = "Key System",
      Note = "",
      FileName = "",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"}
   }
})
