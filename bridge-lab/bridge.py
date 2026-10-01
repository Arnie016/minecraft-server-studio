"""Ashfall Bridge Lab: original, dependency-free planning and frame-policy prototype.

No game connection, injection, installation, compositor, or network listener.
"""
import argparse
import copy
import json
import math

UPSTREAM = '15d6f9d5fbd32de9b1884f29ddec3be9133bd912'
PROFILES = {
    'gta-v-legacy': {
        'title': 'Minecraft × GTA V Legacy', 'platform': 'windows',
        'host_build': '3889', 'minecraft': '26.3',
        'status': 'upstream-reported-working; not reproduced by Ashfall',
        'requirements': ['Fabric Loader >=0.19.5', 'Fabric API 0.161.0+26.3',
                         'JDK 25', 'ScriptHookV 3889.0', 'ReShade 6.8.0 add-on support',
                         'MSVC C++ x64', 'separate Minecraft profile', 'GTA Story Mode'],
        'limitations': ['Windows/NVIDIA is the reported test environment',
                        'GTA Enhanced is not supported by this example',
                        'No Ashfall installer or live adapter yet',
                        'Existing Ashfall Java 1.21.1 packs are not verified on 26.3'],
    },
    'elden-ring': {'title': 'Minecraft × Elden Ring', 'status': 'research-only',
                   'limitations': ['No reviewed adapter or verified version matrix in Ashfall']},
    'assassins-creed': {'title': 'Minecraft × Assassin’s Creed', 'status': 'research-only',
                       'limitations': ['Exact title and supported mod route must be selected first']},
}


def list_bridges() -> list[dict]:
    """List known targets and evidence status; this does not detect installed games."""
    return [dict(id=key, **copy.deepcopy(value)) for key, value in PROFILES.items()]


def plan_bridge(target: str, platform: str, host_build: str = '',
                minecraft: str = '', mode: str = 'offline') -> dict:
    """Produce a plan from user-supplied versions, never an install authorization."""
    if target not in PROFILES:
        raise ValueError('Unknown target; use list_bridges')
    if platform not in ('windows', 'macos', 'linux'):
        raise ValueError('platform must be windows, macos, or linux')
    if mode not in ('offline', 'online'):
        raise ValueError('mode must be offline or online')
    p = copy.deepcopy(PROFILES[target])
    blockers = []
    if mode != 'offline':
        blockers.append('This prototype only plans offline single-player experiments')
    if p['status'] == 'research-only':
        blockers.append('No reviewed game adapter available')
    else:
        for key, actual in [('platform', platform), ('host_build', host_build),
                            ('minecraft', minecraft)]:
            if actual != p[key]:
                blockers.append(f'{key}: expected {p[key]}, received {actual or "unspecified"}')
    return dict(target=target, profile=p, blockers=blockers,
                verdict='blocked' if blockers else 'candidate-for-local-validation',
                playable=False, install_available=False, upstream_commit=UPSTREAM,
                next_steps=['Check the actual local game versions and graphics API',
                            'Build and test in isolated profiles with save backups',
                            'Authenticate the bridge and constrain allowed messages',
                            'Verify camera, depth, collision and event translation',
                            'Verify pause, disconnect and uninstall before distributing'])


def _number(value):
    if type(value) not in (float, int) or not math.isfinite(value):
        raise ValueError('Expected finite number')
    return value


def map_position(position: list[float], y_offset: float = 0,
                 inverse: bool = False) -> list[float]:
    """GTA metres <-> Minecraft blocks for the documented upstream convention."""
    if len(position) != 3:
        raise ValueError('Expected three coordinates')
    x, y, z = [_number(v) for v in position]
    offset = _number(y_offset)
    result = [x, -z, y - offset] if inverse else [x, z + offset, -y]
    return [_number(v) for v in result]


class FrameGate:
    """Simulation of overlay visibility policy; both times use the host clock.

    A future transport stamps received_ms on receipt. Never compare independent
    clocks from two games. Pausing/disconnecting invalidates the previous session.
    Only strictly increasing frame IDs are accepted within a session.
    """
    def __init__(self, max_age_ms=150):
        if _number(max_age_ms) <= 0:
            raise ValueError('max_age_ms must be positive')
        self.max_age_ms = max_age_ms
        self.session = None
        self.frame_id = -1
        self.received_ms = None

    def reset(self, session: str):
        if not isinstance(session, str) or not session:
            raise ValueError('Nonempty session identifier required')
        self.session, self.frame_id, self.received_ms = session, -1, None

    def accept(self, session: str, frame_id: int, received_ms: float) -> bool:
        _number(received_ms)
        if type(frame_id) is not int or frame_id < 0:
            raise ValueError('Nonnegative integer frame ID required')
        if self.session is None or session != self.session or frame_id <= self.frame_id:
            return False
        if self.received_ms is not None and received_ms < self.received_ms:
            return False
        self.frame_id, self.received_ms = frame_id, received_ms
        return True

    def visible(self, now_ms: float, paused=False, connected=True) -> bool:
        _number(now_ms)
        if paused or not connected:
            self.session, self.frame_id, self.received_ms = None, -1, None
            return False
        if self.received_ms is None:
            return False
        return 0 <= now_ms - self.received_ms <= self.max_age_ms


def replay_demo() -> dict:
    """Synthetic policy demonstration, not footage or a running-game test."""
    gate = FrameGate()
    gate.reset('first')
    gate.accept('first', 1, 1000)
    fresh = gate.visible(1050)
    stale = gate.visible(1200)
    paused = gate.visible(1201, paused=True)
    delayed = gate.accept('first', 2, 1202)
    gate.reset('second')
    gate.accept('second', 0, 1300)
    return dict(synthetic=True, fresh_visible=fresh, stale_visible=stale,
                paused_visible=paused, old_session_accepted=delayed,
                resumed_visible=gate.visible(1310),
                sample_minecraft_position=map_position([10, 20, 30], 64))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('list')
    sub.add_parser('demo')
    plan = sub.add_parser('plan')
    plan.add_argument('target', choices=PROFILES)
    plan.add_argument('--platform', required=True, choices=['windows', 'macos', 'linux'])
    plan.add_argument('--host-build', default='')
    plan.add_argument('--minecraft', default='')
    plan.add_argument('--mode', default='offline', choices=['offline', 'online'])
    args = vars(parser.parse_args())
    command = args.pop('command')
    result = list_bridges() if command == 'list' else replay_demo() if command == 'demo' else plan_bridge(**args)
    print(json.dumps(result, indent=2, ensure_ascii=False))
