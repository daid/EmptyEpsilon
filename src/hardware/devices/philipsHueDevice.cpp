//The Hue bridge returns its info in JSON form, so the json11 library takes this role.

#include "philipsHueDevice.h"
#include "hardware/serialDriver.h"
#include "logging.h"
#include <unistd.h>
#include <json11/json11.hpp>

using namespace json11;

PhilipsHueDevice::PhilipsHueDevice()
: update_thread(&PhilipsHueDevice::updateLoop, this)
{
    userfile = "philips_hue.name";
    run_thread = false;
}

PhilipsHueDevice::~PhilipsHueDevice()
{
    if (run_thread)
    {
        run_thread = false;
        update_thread.wait();
    }
}

bool PhilipsHueDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("ip") != settings.end())
    {
        ip_address = settings["ip"];
    }
    if (settings.find("username") != settings.end())
    {
        username = settings["username"];
        userfile = "";
    }
    else if (settings.find("userfile") != settings.end())
    {
        userfile = settings["userfile"];
    }

    if (settings.find("port") != settings.end())
    {
        port = settings["port"].toInt();
    }

    //If no user name set, try to read it from the userfile.
    if (username == "")
    {
        FILE* f = fopen(userfile.c_str(), "rt");
        if (f)
        {
            char buffer[128];
            if (fgets(buffer, sizeof(buffer), f))
                username = string(buffer).strip();
            fclose(f);
        }
    }

    LOG(INFO) << "Attempting to connect to Hue bridge " << ip_address << " on port " << port;

    //If no username was set, or no username was read from the userfile, then we need to request one from the philips hue bridge.
    int retry_counter = 120 / 5;
    while(username == "")
    {
        sf::Http http(ip_address,port);

        LOG(INFO) << "No philips hue username. Going to request one. Be sure to press the button on the hue bridge.";
        sf::Http::Response response = http.sendRequest(sf::Http::Request("/api", sf::Http::Request::Post, "{\"devicetype\":\"EmptyEpsilon#EmptyEpsilon\"}"));
        if (response.getStatus() == sf::Http::Response::Ok)
        {
            string body = response.getBody();
            //The body should contain:
            //  [{"success":{"username": "83b7780291a6ceffbe0bd049104df"}}]
            //As we don't have a full json parse, we just cheat.
            int idx = body.find("\"username\"");
            if (idx > 0)
            {
                idx = body.find(":", idx);
                if (idx > 0)
                {
                    idx = body.find("\"", idx);
                    if (idx > 0)
                    {
                        int end_idx = body.find("\"", idx + 1);
                        if (end_idx > 0)
                        {
                            username = body.substr(idx + 1, end_idx);
                            LOG(INFO) << body;
                            LOG(INFO) << "Got username from philips hue bridge: " << username;
                            break;
                        }
                    }
                }
            }
        }
        else
        {
            LOG(WARNING) << "Failed to contact philips hue bridge: " << response.getStatus();
            LOG(WARNING) << response.getBody();
            if (response.getStatus() == sf::Http::Response::ConnectionFailed)
                return false;
            if (response.getStatus() == sf::Http::Response::NotFound)
                return false;
        }

        if (retry_counter > 0)
            retry_counter--;
        else
        {
            LOG(WARNING) << "Philips hue retry count exceeded.";
            return false;
        }
        sf::sleep(sf::milliseconds(5000));
    }
    
    if (username != "")
    {
        sf::Http http(ip_address,port);
        sf::Http::Response response = http.sendRequest(sf::Http::Request("/api/" + username + "/lights"));
        if (response.getStatus() != sf::Http::Response::Ok)
        {
            LOG(WARNING) << "Failed to validate username on philips hue bridge: " << response.getStatus();
            LOG(WARNING) << response.getBody();
            username = "";

            //Don't delete the username file is the philips hue bridge cannot be accessed, only if it responds with the username not working.
            if (response.getStatus() == sf::Http::Response::ConnectionFailed)
                return false;
            if (response.getStatus() == sf::Http::Response::NotFound)
                return false;

            if (userfile != "")
                unlink(userfile.c_str());
        }
        else
        {
            std::string body = response.getBody();
            std::string err;
            json11::Json hue_json = json11::Json::parse(body,err);
            LOG(ERROR) << "Json parser returned error " << err;

            light_count = 0;
            std::map<std::__cxx11::basic_string<char>, json11::Json> jsonMap = hue_json.object_items();
            for(std::map<std::__cxx11::basic_string<char>,json11::Json>::iterator it = jsonMap.begin(); it != jsonMap.end(); it++) {
                  int currentInt = std::stoi (it->first,nullptr,10); //TODO: Replace STOI with toInt()
                  LOG(DEBUG) << "Got key from Hue API " << currentInt;
                  if (currentInt >= light_count) light_count = currentInt;
            }

            lights.resize(light_count);
            
            FILE* f = fopen(userfile.c_str(), "wt");
            if (f)
            {
                fprintf(f, "%s\n", username.c_str());
                fclose(f);
            }
        }
    }

    if (username != "")
    {
        run_thread = true;
        update_thread.launch();
        return true;
    }
    return false;
}

void PhilipsHueDevice::setChannelData(int channel, float value)
{
    int light_idx = channel / 3;
    if (light_idx < 0 || light_idx >= light_count)
        return;

    sf::Lock lock(mutex);
    switch(channel % 3)
    {
    case 0: if (lights[light_idx].brightness != value * 254) lights[light_idx].dirty = true; lights[light_idx].brightness = value * 254; break;
    case 1: if (lights[light_idx].saturation != value * 254) lights[light_idx].dirty = true; lights[light_idx].saturation = value * 254; break;
    case 2: if (lights[light_idx].hue != value * 65535) lights[light_idx].dirty = true; lights[light_idx].hue = value * 65535; break;
    }
}

int PhilipsHueDevice::getChannelCount()
{
    return light_count * 3;
}

void PhilipsHueDevice::updateLoop()
{
    sf::Http http(ip_address,port);

    while(run_thread)
    {
        for(int n=0; n<light_count; n++)
        {
            if (lights[n].dirty)
            {
                LightInfo info;
                {
                    sf::Lock lock(mutex);
                    lights[n].dirty = false;
                    info = lights[n];
                }
                string post_data;
                if (info.brightness > 0)
                    post_data = "{\"on\":true, \"sat\":"+string(info.saturation)+", \"bri\":"+string(info.brightness)+",\"hue\":"+string(info.hue)+", \"transitiontime\": 0}";
                else
                    post_data = "{\"on\":false, \"transitiontime\": 0}";
                sf::Http::Response response = http.sendRequest(sf::Http::Request("/api/" + username + "/lights/" + string(n + 1) + "/state", sf::Http::Request::Put, post_data));
                if (response.getStatus() != sf::Http::Response::Ok)
                {
                    LOG(WARNING) << "Failed to set light [" << (n + 1) << "] philips hue bridge: " << response.getStatus();
                    LOG(WARNING) << response.getBody();
                }
            }
        }
        sf::sleep(sf::milliseconds(50));
    }
}
