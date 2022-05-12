Locales = {};

function _(str, ...)
    if Locales[Config.Locale] ~= nil then
        if Locales[Config.Locale][str] ~= nil then
            return string.format(Locales[Config.Locale][str], ...);
        else
            return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exists';
        end
    else
        return 'Locale [' .. Config.Locale .. '] does not exists';
    end
end
