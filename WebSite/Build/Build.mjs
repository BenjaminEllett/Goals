/*
    Useful Documentation:

    https://esbuild.github.io/
        - Main ESBuild Web Site

*/
import * as esbuild from 'esbuild';

//
// Enums
//

const BuildType = Object.freeze({
    Debug: 'Debug',
    Release: 'Release'
});

const RequestedAction = Object.freeze({
    Build: 'Build',
    BuildAndServeWebSite: 'BuildAndServeWebSite'
});

//
// Main functions
//

async function Main()
{
    const commandLineArguments = ParseCommandLineArguments()

    switch (commandLineArguments.RequestedAction)
    {
        case RequestedAction.Build:
            await BuildWebSite(commandLineArguments.BuildType);
            break;

        case RequestedAction.BuildAndServeWebSite:
            await ConstantlyBuildChangesAndCreateDevelopmentServer(commandLineArguments.BuildType);
            break;

        default:
            throw new Error(`This case should never occur.  If you see this error, please report it.`);
    }
}

function ParseCommandLineArguments()
{
    // Remove the path to the node process and the path to JavaScript file node is running.
    // For more information, please see https://nodejs.org/api/process.html#processargv .
    let commandLineArguments = process.argv.slice(2);

    //
    // Make sure there are no invalid command line arguments
    //

    let validCommandLineArguments = [
        '--debug',
        '--release',
        '--build',
        '--build-and-serve-web-site'
    ];

    // "The find() method of Array instances returns the first element in the provided array that satisfies the provided testing function. 
    // If no values satisfy the testing function, undefined is returned." 
    // (https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find)
    let invalidCommandLineArgument = commandLineArguments.find((argument) => !validCommandLineArguments.includes(argument));
    if (undefined != invalidCommandLineArgument)
    {
        throw new Error(
            `The user passed in an invalid command line argument.  Here is the invalid argument: ${invalidCommandLineArgument}`);
    }

    //
    // Parse the build type (debug or release) command line arguments
    //

    if (commandLineArguments.includes('--debug') && commandLineArguments.includes('--release'))
    {
        throw new Error(
            `The build script cannot build both a debug and release build at the same time.  Please specify --debug or --release, but not both.`);
    }

    let buildType = undefined;

    if (commandLineArguments.includes('--debug'))
    {
        buildType = BuildType.Debug;
    }
    else if (commandLineArguments.includes('--release'))
    {
        buildType = BuildType.Release;
    }
    else 
    {
        // Default to debug builds because they are the most common type of build.
        buildType = BuildType.Debug;
    }   

    //
    // Parse the action command line arguments
    //

    if (commandLineArguments.includes('--build') && commandLineArguments.includes('--build-and-serve-web-site'))
    {
        throw new Error(
            `The --build and --build-and-serve-web-site cannot both be specified.  Please use one or the other.`);
    }

    let requestedAction = undefined;

    if (commandLineArguments.includes('--build'))
    {
        requestedAction = RequestedAction.Build;
    }
    else if (commandLineArguments.includes('--build-and-serve-web-site'))
    {
        requestedAction = RequestedAction.BuildAndServeWebSite;
    }
    else 
    {
        // Default to --build-and-serve-web-site builds because most people running the script are
        // developers and they will be debugging or testing the web site.
        requestedAction = RequestedAction.BuildAndServeWebSite;
    }   

    return {
        BuildType: buildType,
        RequestedAction: requestedAction
    };
}

async function BuildWebSite(buildType)
{
    let buildConfiguration = CreateESBuildConfiguration(buildType);
    await esbuild.build(buildConfiguration);
}

async function ConstantlyBuildChangesAndCreateDevelopmentServer(buildType)
{
    let buildConfiguration = CreateESBuildConfiguration(buildType);
    let ctx = await esbuild.context(buildConfiguration);
    
    // "Watch mode tells esbuild to watch the file system and automatically rebuild for you whenever you edit and save a file that could 
    // invalidate the build." (https://esbuild.github.io/api/#build)
    await ctx.watch();
    
    // "Serve mode starts a local development server that serves the results of the latest build. Incoming requests automatically start new
    // builds so your web app is always up to date when you reload the page in the browser." (https://esbuild.github.io/api/#build).  For
    // more information on Serve, please see https://esbuild.github.io/api/#serve .
    await ctx.serve({
        host: '::1', // IPv6 loopback address
        port: 37351, // This port was chosen randomly.  
    
        servedir: GetBuildOutputDirectoryRelativePath(),
    });    
}

function GetBuildOutputDirectoryRelativePath()
{
    return './BuildOutput';
}

function CreateESBuildConfiguration(buildType) 
{
    // TODO: Add the following options when needed:
    // - https://esbuild.github.io/api/#outbase
    // - https://esbuild.github.io/api/#asset-names
    // - https://esbuild.github.io/api/#entry-names
    // - https://esbuild.github.io/api/#source-root

    let isReleaseBuild = buildType == BuildType.Release; 
    let isDebugBuild = buildType == BuildType.Debug;

    let buildOutputDirectoryRelativePath = GetBuildOutputDirectoryRelativePath();

    // For more information on valid values, please see https://esbuild.github.io/api/#sourcemap.  Note
    // that true is a valid value and means that the source map is linked to the output file (i.e. the 
    // output file has a comment which tells the debugger where to find the source map).
    let sourceMapType = isReleaseBuild ? 'external' : true;

    return {
        platform: 'browser', // https://esbuild.github.io/api/#platform
        target: 'es2022',
        define: { // https://esbuild.github.io/api/#define
            'DEBUG': isDebugBuild ? 'true' : 'false'
        },
        
        // Code generation settings
        bundle: true, // https://esbuild.github.io/api/#bundle
        minify: isReleaseBuild, // https://esbuild.github.io/api/#minify
        keepNames: false, // https://esbuild.github.io/api/#keep-names
        sourcemap: true, // https://esbuild.github.io/api/#source-maps

        // We add the source code to the source map because it makes it easier to debug issues in production.
        // We do not add the source code in debug builds because it slows down the build and the source code
        // is readily available on the developer's machine.
        sourcesContent: isReleaseBuild, // https://esbuild.github.io/api/#sources-content 
        
        // Entry Point and Output Settings
        entryPoints: ['./src/index.tsx'], // https://esbuild.github.io/api/#entry-points
        outfile: `${buildOutputDirectoryRelativePath}/index.js`,  

        // JSX Settings
        jsx: 'automatic', // https://esbuild.github.io/api/#jsx
        jsxDev: isDebugBuild, // https://esbuild.github.io/api/#jsx-dev
        jsxSideEffects: false, // https://esbuild.github.io/api/#jsx-side-effects

        // Logging settings
        logLevel: 'info', // https://esbuild.github.io/api/#log-level
        logLimit: 0, // Disable log limit - https://esbuild.github.io/api/#log-limit
    };
}

await Main();