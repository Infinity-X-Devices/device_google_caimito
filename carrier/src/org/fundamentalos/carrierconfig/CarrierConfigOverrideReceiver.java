/*
 * Copyright (C) 2026 The FundamentalOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 */
package org.infinity.carrierconfig;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.PersistableBundle;
import android.telephony.CarrierConfigManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.util.Log;

import java.util.List;

/**
 * Re-applies carrier-config overrides (force 5G NSA+SA, force VoLTE) on top of
 * whatever the carrier config app provides, using the official CarrierConfigManager
 * overrideConfig API. Google per-carrier configs (e.g. chinamobile_cn) restrict
 * carrier_nr_availabilities to NSA-only, so 5G SA never engages; AOSP default is already
 * NSA+SA, so we simply re-assert it as an override.
 *
 * Runs on every ACTION_CARRIER_CONFIG_CHANGED: the override is applied as soon as config
 * loads (before the modem settles, so SA engages from the first boot without a modem
 * restart), and it self-heals if a later config reload drops it. A guard skips re-applying
 * when the merged config already reflects our values, so overrideConfig does not loop.
 */
public class CarrierConfigOverrideReceiver extends BroadcastReceiver {
    private static final String TAG = "InfinityCarrierCfg";

    @Override
    public void onReceive(Context context, Intent intent) {
        final CarrierConfigManager ccm = context.getSystemService(CarrierConfigManager.class);
        final SubscriptionManager sm = context.getSystemService(SubscriptionManager.class);
        if (ccm == null || sm == null) {
            return;
        }

        final int subId = intent.getIntExtra(CarrierConfigManager.EXTRA_SUBSCRIPTION_INDEX,
                SubscriptionManager.INVALID_SUBSCRIPTION_ID);
        if (SubscriptionManager.isValidSubscriptionId(subId)) {
            applyIfNeeded(ccm, subId);
            return;
        }

        // BOOT_COMPLETED or a change without a specific sub: apply to every active sub.
        final List<SubscriptionInfo> subs = sm.getActiveSubscriptionInfoList();
        if (subs == null) {
            return;
        }
        for (SubscriptionInfo si : subs) {
            applyIfNeeded(ccm, si.getSubscriptionId());
        }
    }

    private void applyIfNeeded(CarrierConfigManager ccm, int subId) {
        final PersistableBundle current = ccm.getConfigForSubId(subId);
        if (current != null && isAlreadyApplied(current)) {
            return;
        }

        final PersistableBundle overrides = new PersistableBundle();
        overrides.putIntArray(CarrierConfigManager.KEY_CARRIER_NR_AVAILABILITIES_INT_ARRAY,
                new int[] {
                        CarrierConfigManager.CARRIER_NR_AVAILABILITY_NSA,
                        CarrierConfigManager.CARRIER_NR_AVAILABILITY_SA
                });
        overrides.putBoolean(CarrierConfigManager.KEY_CARRIER_VOLTE_AVAILABLE_BOOL, true);
        overrides.putBoolean(
                CarrierConfigManager.KEY_CARRIER_VOLTE_PROVISIONING_REQUIRED_BOOL, false);
        overrides.putBoolean(CarrierConfigManager.KEY_CARRIER_WFC_IMS_AVAILABLE_BOOL, true);

        try {
            // persistent=true: stored in the persistent override layer so CarrierConfigLoader
            // re-applies it before the modem registers on the next boot (engages 5G SA on reboot).
            ccm.overrideConfig(subId, overrides, true);
            Log.i(TAG, "Applied 5G NSA+SA and VoLTE override for subId " + subId);
        } catch (Exception e) {
            Log.e(TAG, "overrideConfig failed for subId " + subId, e);
        }
    }

    private boolean isAlreadyApplied(PersistableBundle config) {
        final int[] nr = config.getIntArray(
                CarrierConfigManager.KEY_CARRIER_NR_AVAILABILITIES_INT_ARRAY);
        final boolean nrOk = contains(nr, CarrierConfigManager.CARRIER_NR_AVAILABILITY_NSA)
                && contains(nr, CarrierConfigManager.CARRIER_NR_AVAILABILITY_SA);
        final boolean volteOk =
                config.getBoolean(CarrierConfigManager.KEY_CARRIER_VOLTE_AVAILABLE_BOOL, false)
                && !config.getBoolean(
                        CarrierConfigManager.KEY_CARRIER_VOLTE_PROVISIONING_REQUIRED_BOOL, true);
        return nrOk && volteOk;
    }

    private static boolean contains(int[] array, int value) {
        if (array == null) {
            return false;
        }
        for (int v : array) {
            if (v == value) {
                return true;
            }
        }
        return false;
    }
}
