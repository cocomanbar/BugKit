/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#ifdef ALLOCATION_TRACKER_ENABLED
#define _INTERNAL_FBAT_ENABLED (ALLOCATION_TRACKER_ENABLED)
#else
#define _INTERNAL_FBAT_ENABLED DEBUG
#endif // ALLOCATION_TRACKER_ENABLED
