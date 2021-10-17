import XMonad
import Data.Monoid
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Layout.Gaps
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.DynamicLog
import XMonad.Actions.SpawnOn

myTerminal      = "st"
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myBorderWidth   = 3
myModMask       = mod4Mask
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor  = "#ffffff"
myFocusedBorderColor = "#81a1c1"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm,               xK_a     ), spawn "dmenu_run")
    , ((modm,               xK_Return), spawn "st")
    , ((modm,               xK_p     ), spawn "picom -e 0.9 -D 1")
    , ((modm .|. shiftMask, xK_p     ), spawn "pkill picom")
    , ((modm,               xK_r     ), spawn "firefox")
    , ((modm .|. shiftMask, xK_r     ), spawn "brave-nightly")
    , ((modm,               xK_i     ), spawn "slock")
    , ((modm,               xK_f     ), spawn "mpc play")
    , ((modm,               xK_s     ), spawn "mpc pause")
    , ((modm .|. shiftMask, xK_s     ), spawn "scrot -s -z -e 'mv $f ~/pics/screenshots' --line style=dash,width=3")
    , ((modm,               xK_c     ), spawn "mpc prev")
    , ((modm,               xK_v     ), spawn "mpc next")
    , ((modm,               xK_o     ), spawn "doas protonvpn c -f")
    , ((modm .|. shiftMask, xK_o     ), spawn "doas protonvpn d")
    , ((modm,               xK_u     ), spawn "doas macchanger -r enp0s25")
    , ((modm .|. shiftMask, xK_u     ), spawn "doas macchanger -p enp0s25")
    , ((0, xF86XK_AudioMute          ), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ((0, xF86XK_AudioLowerVolume   ), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    , ((modm,               xK_w     ), kill)
    , ((modm,               xK_space ), sendMessage NextLayout)
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm,               xK_n     ), refresh)
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm,               xK_q     ), windows W.focusUp)
    , ((modm,               xK_m     ), windows W.focusMaster)
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_n     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_e     ), windows W.swapUp    )
    , ((modm,               xK_z     ), sendMessage Shrink)
    , ((modm,               xK_x     ), sendMessage Expand)
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm,               xK_comma ), sendMessage (IncMasterN 1))
    , ((modm,               xK_period), sendMessage (IncMasterN (-1)))
    , ((modm .|. shiftMask, xK_b     ), sendMessage $ ToggleGaps)
    , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm .|. shiftMask, xK_y     ), io (exitWith ExitSuccess))
    , ((modm              , xK_y     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --    | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    --    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
------------------------------------------------------------------------
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    tiled = gaps [(U,15), (R,15), (D,15), (L,15) ] $ spacing 5 $ Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio   = 1/2
    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

--myManageHook = composeAll
--    [ className =? "MPlayer"        --> doFloat
--    , className =? "Gimp"           --> doFloat
--    , resource  =? "desktop_window" --> doIgnore
--    , resource  =? "kdesktop"       --> doIgnore ]

myEventHook = mempty
myLogHook = return ()
myStartupHook = do
        spawn "xrdb /home/easton/.Xresources"
        spawn "xwallpaper --zoom /home/easton/.config/wall.png"
        spawn "setxkbmap us -variant colemak"
        spawn "mpd &"
	--spawnOn "2" "/usr/local/bin/st"
	--spawnOn "2" "/usr/local/bin/st"
	--spawnOn "2" "/usr/local/bin/st"

main = do
        xmproc <- spawnPipe "xmobar /home/easton/.xmobarrc &"
        xmonad $ defaults

defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
--      manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
