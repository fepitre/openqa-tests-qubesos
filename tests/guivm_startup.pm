# The Qubes OS Project, https://www.qubes-os.org/
#
# Copyright (C) 2020 Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use base "installedtest";
use strict;
use testapi;


sub run {
    select_console('x11');
    assert_screen "desktop";

    # FIXME: change to serial console, don't assume x11 session in dom0
    x11_start_program('xterm');
    assert_script_run("qvm-shutdown --all --wait", 180);
    assert_script_run("qubes-prefs default_guivm sys-gui");
    assert_script_run("qvm-start sys-firewall", 180);
    assert_script_run("! qvm-check sys-whonix || qvm-start sys-whonix", 90);
    assert_script_run("tail -F /var/log/xen/console/guest-sys-gui.log >> /dev/$testapi::serialdev & true");

    type_string("exit\n");

    assert_and_click("panel-user-menu");
    assert_and_click("panel-user-menu-logout");
    assert_and_click("panel-user-menu-confirm");

    assert_screen("login-prompt-user-selected");
    assert_and_click("login-prompt-session-type-menu");
    assert_and_click("login-prompt-session-type-gui-domains");
    type_string $testapi::password;
    send_key "ret";

    assert_screen("desktop", timeout => 90);

    # FIXME: make it packaged, rc.local or such
    select_console('root-virtio-terminal');
    assert_script_run("echo -e '$testapi::password\n$testapi::password' | qvm-run -p -u root sys-gui 'passwd --stdin user'");
    select_console('x11');

}

sub post_fail_hook {
    my ($self) = @_;
    save_screenshot;
    $self->SUPER::post_fail_hook;

};

1;

# vim: set sw=4 et:

