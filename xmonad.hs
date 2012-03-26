-- dmr's xmonad
-- TODO:
-- 
-- http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Util-XSelection.html
-- for pasting with trackpad &such
-- 
-- submaps: handy

import System.IO
import Data.Monoid(mempty)
import Text.Format

import XMonad
import qualified XMonad.StackSet as W

import XMonad.Actions.CopyWindow(kill1)
import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import XMonad.Layout.BoringWindows
import XMonad.Layout.Minimize

import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.XMonad

import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad (scratchpadManageHook, scratchpadSpawnActionCustom, scratchpadSpawnActionTerminal)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run(spawnPipe)

myTerminal = "uxterm"

--myStatusOffsets = Map.fromList [("d0", offset0), ("d1", offset1), ("w0", width0), ("w1", width1)] where
myStatusOffsets :: [Int]
myStatusOffsets = [offset0, width0, offset1, width1] where
  --width0 = 960
  width0 = 1280
  offset0 = 1920
  offset1 = offset0 + width0
  width1  = total - width0 - noteWidth
  -- defined in startup.sh
  noteWidth = 120
  total = 1920
  
myStatusBar :: String
myStatusBar = format
              "dzen2 -x {0} -w {1} -y '0' -h '16' -ta 'l' -fg '#FFFFFF' -bg '#000000'" 
              (map show (take 2 myStatusOffsets))

secondStatsBar :: String
secondStatsBar = format
                 "/home/dmr/.xmonad/scripts/2nd-status.sh | dzen2 -x {0} -y '0' -h 16 -w {1} -ta r -sa l -fg #FFFFFF -bg #000000" 
                 (map show (drop 2 myStatusOffsets))

--myLayoutHook = layoutHook defaultConfig
--myLayoutHook = avoidStruts $ layoutHook defaultConfig
--myLayoutHook = avoidStruts $ (Tall 1 (3/100) (1/2) ||| Full)
myLayoutHook = minimize $ boringAuto $ avoidStruts $ (Tall 1 (3/100) (1/2) ||| Full)

--myEventHook = docksEventHook
myEventHook = mempty

myBarHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor "#3EB5FF" "black" . pad
      , ppVisible           =   dzenColor "white" "black" . pad
      , ppHidden            =   dzenColor "white" "black" . pad
      , ppHiddenNoWindows   =   dzenColor "#444444" "black" . pad
      , ppUrgent            =   dzenColor "red" "black" . pad
      , ppWsSep             =   " "
      , ppSep               =   "  |  "
      , ppTitle             =   (" " ++) . dzenColor "white" "black" . dzenEscape
      , ppOutput            =   hPutStrLn h
    }

myUpdate = updatePointer (Relative 0 0)

myManageHook = manageScratchPad <+> manageDocks
--myManageHook = manageScratchPad

myUnboundKeys = ["M-,", "M-.", "S-M-q"]

myKeys = [ ("M-z", scratchPad),
           ("S-M-c", kill1),
           ("M-[", windowPromptBringCopy defaultXPConfig),
           
           -- misc testing
           --("M-`", xmonadPrompt defaultXPConfig),
           
           -- inconvenient bindings for testing
           ("S-M-=", withFocused (\f -> sendMessage (MinimizeWin f))),
           ("S-M--", sendMessage RestoreNextMinimizedWin)
           --("S-M-=", kill1),
           --("S-M--", windowPromptBringCopy defaultXPConfig)
         ]

manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook (W.RationalRect l t w h)
  where
    -- h = 0.1     -- terminal height, 10% 
    -- w = 1       -- terminal width, 100%
    -- t = 1 - h   -- distance from top edge, 90%
    -- l = 1 - w   -- distance from left edge, 0%
    
    h = 0.33    -- terminal height
    w = 0.45    -- terminal width
    t = 1 - h   -- distance from top edge
    l = 1 - w   -- distance from left edge

    
    
--scratchPad = scratchpadSpawnActionCustom myTerminal    
scratchPad = scratchpadSpawnActionTerminal myTerminal

-- scratchpads = [
--   NS "foo" "" 
--     (title =? "Foo") 
--     (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
-- ]
  
-- faq: screens in wrong order
extraKeys = [] ++ 
         [  (mask ++ "M-" ++ [key], screenWorkspace scr >>= flip whenJust (windows . action))
         | (key, scr)  <- zip "wer" [1,0] -- was [0..] *** change to match your screen order ***
         , (action, mask) <- [ (W.view, "") , (W.shift, "S-")]
         ]
  
modm = mod4Mask
-- end faq

-- xmobar
-- http://www.linuxandlife.com/2011/11/how-to-configure-xmonad-arch-linux.html
-- end xmobar


main = do
  spawn secondStatsBar
  workspaceBar <- spawnPipe myStatusBar
  xmonad $ defaultConfig {
    layoutHook = myLayoutHook,
    logHook = myUpdate >> myBarHook workspaceBar,
    manageHook = myManageHook,
    handleEventHook    = myEventHook,

    
    borderWidth = 1,
    --terminal = "uxterm"
    terminal = myTerminal
    } `additionalKeysP` myKeys `additionalKeysP` extraKeys `removeKeysP` myUnboundKeys