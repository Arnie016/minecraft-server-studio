import math
import random
import unittest
from bridge import FrameGate, list_bridges, map_position, plan_bridge, replay_demo


class BridgeTests(unittest.TestCase):
    def test_roundtrip_coordinates(self):
        rng = random.Random(19)
        for _ in range(100):
            point = [rng.uniform(-1000, 1000) for _ in range(3)]
            out = map_position(map_position(point, 64), 64, inverse=True)
            for expected, actual in zip(point, out):
                self.assertAlmostEqual(expected, actual)
        self.assertEqual(map_position([10, 20, 30], 64), [10, 94, -20])

    def test_reject_nonfinite_coordinates(self):
        for value in (math.nan, math.inf, True, '1'):
            with self.assertRaises(ValueError):
                map_position([value, 0, 0])

    def test_plan_never_claims_playable(self):
        plan = plan_bridge('gta-v-legacy', 'windows', '3889', '26.3')
        self.assertEqual(plan['verdict'], 'candidate-for-local-validation')
        self.assertFalse(plan['playable'])
        self.assertFalse(plan['install_available'])
        for platform in ('macos', 'linux'):
            self.assertEqual(plan_bridge('gta-v-legacy', platform)['verdict'], 'blocked')

    def test_unsupported_build_and_mode(self):
        for build, mc, mode in [('Enhanced', '26.3', 'offline'),
                                ('3889', '1.21.1', 'offline'), ('3889', '26.3', 'online')]:
            self.assertTrue(plan_bridge('gta-v-legacy', 'windows', build, mc, mode)['blockers'])
        for target in ('elden-ring', 'assassins-creed'):
            self.assertEqual(plan_bridge(target, 'windows')['verdict'], 'blocked')
        with self.assertRaises(ValueError):
            plan_bridge('unknown', 'windows')

    def test_profiles_are_not_mutable_through_results(self):
        profiles = list_bridges()
        profiles[0]['limitations'].clear()
        self.assertTrue(list_bridges()[0]['limitations'])

    def test_stale_pause_disconnect_and_reconnect(self):
        gate = FrameGate(150)
        self.assertFalse(gate.visible(0))
        gate.reset('a')
        self.assertTrue(gate.accept('a', 1, 1000))
        self.assertTrue(gate.visible(1150))
        self.assertFalse(gate.visible(1151))
        self.assertFalse(gate.visible(999))
        self.assertFalse(gate.visible(1050, paused=True))
        self.assertFalse(gate.accept('a', 2, 1060))
        gate.reset('b')
        self.assertFalse(gate.accept('a', 3, 1070))
        self.assertTrue(gate.accept('b', 0, 1080))
        self.assertTrue(gate.visible(1090))
        self.assertFalse(gate.visible(1100, connected=False))
        self.assertFalse(gate.visible(1110))

    def test_frame_order(self):
        gate = FrameGate()
        gate.reset('x')
        gate.accept('x', 3, 100)
        self.assertFalse(gate.accept('x', 3, 101))
        self.assertFalse(gate.accept('x', 2, 102))
        self.assertFalse(gate.accept('x', 4, 99))
        with self.assertRaises(ValueError):
            gate.accept('x', 4, math.nan)

    def test_demo(self):
        result = replay_demo()
        self.assertTrue(result['synthetic'])
        self.assertTrue(result['fresh_visible'])
        self.assertFalse(result['stale_visible'])
        self.assertFalse(result['old_session_accepted'])
        self.assertTrue(result['resumed_visible'])


if __name__ == '__main__':
    unittest.main()
