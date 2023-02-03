
/*
TODO
    if (game_server)
    {
        if (scanning_target)
        {
            // If the scan setting or a target's scan complexity is none/0,
            // complete the scan after a delay.
            if (scanning_complexity < 1)
            {
                scanning_delay -= delta;
                if (scanning_delay < 0)
                {
                    scanning_target->scannedBy(this);
                    scanning_target = NULL;
                }
            }
        }else{
            // Otherwise, ignore the scanning_delay setting.
            scanning_delay = 0.0;
        }
    }else{
        // Actions performed on the client-side only.

        // If scan settings or the scan target's complexity is 0/none, tick
        // the scan delay timer.
        if (scanning_complexity < 1)
        {
            if (scanning_delay > 0.0f)
                scanning_delay -= delta;
        }
    }
*/