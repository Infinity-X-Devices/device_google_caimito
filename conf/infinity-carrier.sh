#!/system/bin/sh
# (caimito): force 5G NSA+SA for all carriers.
# Google's per-carrier configs (e.g. chinamobile_cn) restrict carrier_nr_availabilities to
# NSA-only ([1]); China Mobile and others run 5G SA, so SA never engages -> LTE only.
# Override it to [1,2] (NSA+SA) via the persistent carrier-config override layer, which is
# merged AFTER the carrier-app config (wins over it) and keeps every other key intact.
# `cmd phone cc` needs ROOT_UID (this service runs as root); -p persists + is restored by
# CarrierConfigLoader on every config reload.
i=0
while [ $i -lt 40 ]; do
    case "$(getprop gsm.sim.state)" in *LOADED*) break;; esac
    sleep 2; i=$((i+1))
done
for slot in 0 1 2; do
    # 5G NSA+SA
    cmd phone cc set-value -s "$slot" -p carrier_nr_availabilities_int_array 1 2 2>/dev/null
    # VoLTE / VoWiFi (validated: CMCC comes up on NR_SA + VoLTE with these forced on; no provisioning gate)
    cmd phone cc set-value -s "$slot" -p carrier_volte_available_bool true 2>/dev/null
    cmd phone cc set-value -s "$slot" -p carrier_volte_provisioning_required_bool false 2>/dev/null
    cmd phone cc set-value -s "$slot" -p carrier_wfc_ims_available_bool true 2>/dev/null
done

# First boot after a factory reset: the persistent -p overrides above did not exist
# when the modem first registered, so it is already camped on LTE and will not
# re-evaluate NR until the radio re-registers. On every later NORMAL boot the
# persisted override IS applied before registration, so 5G SA comes up on its own;
# only this very first post-wipe boot misses it. Force one modem restart so SA
# engages now instead of requiring the user to reboot once. Guarded by a marker in
# /data (wiped by factory reset, kept across reboots) so normal boots never take
# this radio blip.
MARKER=/data/local/tmp/.fundamental_carrier_firstboot
if [ ! -e "$MARKER" ]; then
    sleep 3
    cmd phone restart-modem 2>/dev/null
    : > "$MARKER" 2>/dev/null
fi
